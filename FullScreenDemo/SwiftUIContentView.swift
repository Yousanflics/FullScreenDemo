import SwiftUI

struct SwiftUIContentView: View {
    @StateObject private var playerViewModel = PlayerViewModel()
    
    var body: some View {
        ZStack {
            // 主要背景 - 黑色
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // 非全屏模式下的容器视图 - 使用opacity而非条件渲染，避免闪烁
            VStack {
                // 播放器容器视图
                ZStack {
                    // 播放器视图
                    SwiftUIPlayerViewWrapper(viewModel: playerViewModel)
                        .frame(height: 250)
                }
                
                Spacer()
            }
            .opacity(playerViewModel.isFullScreen ? 0 : 1)
            .allowsHitTesting(!playerViewModel.isFullScreen)
            
            // 全屏模式下的播放器视图 - 使用opacity而非条件渲染，避免闪烁
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                SwiftUIPlayerViewWrapper(viewModel: playerViewModel)
                    .edgesIgnoringSafeArea(.all)
            }
            .opacity(playerViewModel.isFullScreen ? 1 : 0)
            .allowsHitTesting(playerViewModel.isFullScreen)
        }
        .deviceOrientation(playerViewModel)
        .hostingController(playerViewModel)
        .onAppear {
            // 确保初始状态为竖屏
            playerViewModel.rotate(to: .portrait)
        }
    }
}

// MARK: - 播放器视图包装器，处理代理方法
struct SwiftUIPlayerViewWrapper: View {
    @ObservedObject var viewModel: PlayerViewModel
    
    var body: some View {
        SwiftUIPlayerView(delegate: self)
            .environmentObject(viewModel)
    }
}

// MARK: - 实现代理方法
extension SwiftUIPlayerViewWrapper: SwiftUIPlayerViewDelegate {
    func playerViewDidToggleFullScreen(_ isFullScreen: Bool) {
        viewModel.toggleFullScreen(isFullScreen)
    }
    
    func playerViewDidRequestRotate(to orientation: UIInterfaceOrientation) {
        viewModel.rotate(to: orientation)
    }
}

// MARK: - 预览
struct SwiftUIContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIContentView()
    }
} 
