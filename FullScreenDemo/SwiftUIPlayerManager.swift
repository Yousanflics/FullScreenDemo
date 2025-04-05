import SwiftUI
import Combine

// MARK: - 播放器状态
class PlayerViewModel: ObservableObject {
    @Published var isFullScreen: Bool = false
    @Published var orientationLock: UIInterfaceOrientationMask = .all
    @Published var prefersHomeIndicatorAutoHidden: Bool = false
    @Published private var isTransitioning: Bool = false // 添加过渡状态标志
    
    // 用于切换全屏状态
    func toggleFullScreen(_ fullScreen: Bool) {
        // 如果已经在过渡中，忽略本次操作
        if isTransitioning {
            return
        }
        
        // 设置过渡标志
        isTransitioning = true
        
        if fullScreen {
            // 进入全屏模式
            // 首先旋转到横屏
            rotate(to: .landscapeRight)
            
            // 然后更新UI状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.isFullScreen = fullScreen
                    self.prefersHomeIndicatorAutoHidden = fullScreen
                }
                self.isTransitioning = false
            }
        } else {
            // 退出全屏模式
            // 先把方向锁定设置为同时支持横屏和竖屏，防止旋转时跳变
            orientationLock = [.portrait, .landscape]
            
            // 然后在一个操作中同时完成UI更新和设备旋转
            DispatchQueue.main.async {
                // 先更新UI到竖屏状态
                withAnimation(.easeOut(duration: 0.2)) {
                    self.isFullScreen = false
                    self.prefersHomeIndicatorAutoHidden = false
                }
                
                // 同时旋转设备
                UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
                
                // 延迟一点时间后锁定为竖屏，并重置过渡标志
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.orientationLock = .portrait
                    self.isTransitioning = false
                }
            }
        }
    }
    
    // 用于改变设备方向
    func rotate(to orientation: UIInterfaceOrientation) {
        // 设置方向锁定
        switch orientation {
        case .portrait:
            orientationLock = .portrait
        case .landscapeLeft, .landscapeRight:
            orientationLock = .landscape
        default:
            orientationLock = .all
        }
        
        // 设置设备方向
        let deviceOrientation: UIDeviceOrientation
        switch orientation {
        case .landscapeLeft:
            deviceOrientation = .landscapeRight
        case .landscapeRight:
            deviceOrientation = .landscapeLeft
        case .portrait:
            deviceOrientation = .portrait
        case .portraitUpsideDown:
            deviceOrientation = .portraitUpsideDown
        default:
            deviceOrientation = .portrait
        }
        
        // 强制性地设置设备方向
        UIDevice.current.setValue(deviceOrientation.rawValue, forKey: "orientation")
        
        // 确保方向改变生效
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

// MARK: - 控制设备方向的修饰器
struct DeviceOrientationModifier: ViewModifier {
    @ObservedObject var viewModel: PlayerViewModel
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    // 如果有必要，可以在此处添加额外的方向改变处理逻辑
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
            }
    }
}

// MARK: - 主机状态修饰器
struct HostingControllerModifier: ViewModifier {
    @ObservedObject var viewModel: PlayerViewModel
    
    func body(content: Content) -> some View {
        content
            .background(HostingControllerSetter(viewModel: viewModel))
    }
}

// MARK: - 用于设置HostingController属性的UIKit桥接
struct HostingControllerSetter: UIViewControllerRepresentable {
    @ObservedObject var viewModel: PlayerViewModel
    
    func makeUIViewController(context: Context) -> HostingController {
        return HostingController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: HostingController, context: Context) {
        uiViewController.updateOrientationLock(viewModel.orientationLock)
        // 不再直接设置prefersHomeIndicatorAutoHidden属性，而是更新HostingController中的相关状态
        uiViewController.shouldHideHomeIndicator = viewModel.prefersHomeIndicatorAutoHidden
    }
}

// MARK: - 自定义的HostingController用于控制屏幕方向
class HostingController: UIViewController {
    var viewModel: PlayerViewModel
    // 添加一个变量来存储是否应该隐藏Home指示器
    var shouldHideHomeIndicator: Bool = false {
        didSet {
            // 当状态变化时，触发UI更新
            if shouldHideHomeIndicator != oldValue {
                setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
        }
    }
    
    // 添加一个变量来存储是否隐藏状态栏
    var shouldHideStatusBar: Bool = false {
        didSet {
            // 当状态变化时，触发UI更新
            if shouldHideStatusBar != oldValue {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        // 添加对viewModel的观察
        viewModel.$isFullScreen.sink { [weak self] isFullScreen in
            self?.shouldHideStatusBar = isFullScreen
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateOrientationLock(_ orientationLock: UIInterfaceOrientationMask) {
        // 在这里设置方向锁定会触发视图控制器重新计算支持的方向
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = orientationLock
        }
        
        // 强制更新状态栏，这将间接触发方向重新计算
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // 重写此属性，根据shouldHideHomeIndicator状态返回值
    override var prefersHomeIndicatorAutoHidden: Bool {
        return shouldHideHomeIndicator
    }
    
    // 重写此属性以控制状态栏的可见性
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    // 设置状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // 设置状态栏隐藏/显示动画
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // 返回我们设置的方向锁定
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.orientationLock
        }
        return .all
    }
}

// MARK: - 扩展 View 以便于使用修饰器
extension View {
    func deviceOrientation(_ viewModel: PlayerViewModel) -> some View {
        self.modifier(DeviceOrientationModifier(viewModel: viewModel))
    }
    
    func hostingController(_ viewModel: PlayerViewModel) -> some View {
        self.modifier(HostingControllerModifier(viewModel: viewModel))
    }
} 
