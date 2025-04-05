import SwiftUI
import Combine

// MARK: - 播放器视图协议
protocol SwiftUIPlayerViewDelegate {
    func playerViewDidToggleFullScreen(_ isFullScreen: Bool)
    func playerViewDidRequestRotate(to orientation: UIInterfaceOrientation)
}

// MARK: - 播放器视图
struct SwiftUIPlayerView: View {
    // 状态
    @State private var isRotated: Bool = false
    @EnvironmentObject private var viewModel: PlayerViewModel
    
    // 代理
    var delegate: SwiftUIPlayerViewDelegate?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 播放区域（橙色背景）
                Rectangle()
                    .fill(Color.orange)
                    .edgesIgnoringSafeArea(viewModel.isFullScreen ? .all : [])
                
                // 中央的蓝色方块控制元素
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                
                // 控制区域 - 使用opacity实现平滑过渡
                
                // 全屏模式 - 左侧控制栏
                HStack(spacing: 0) {
                    // 左侧控制栏
                    VStack {
                        Spacer()
                        
                        // 退出全屏按钮（绿色）- 放在底部
                        Button(action: {
                            delegate?.playerViewDidToggleFullScreen(false)
                        }) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                        }
                        .padding(.bottom, 20)
                    }
                    .frame(width: 80)
                    .background(Color.yellow)
                    
                    Spacer() // 让控制栏靠左
                }
                .opacity(viewModel.isFullScreen ? 1 : 0)
                .edgesIgnoringSafeArea(.all)
                
                // 非全屏模式 - 底部控制栏
                VStack {
                    Spacer()
                    
                    // 底部控制栏（黄色背景）
                    HStack {
                        Spacer()
                        
                        // 全屏按钮（绿色）
                        Button(action: {
                            delegate?.playerViewDidToggleFullScreen(true)
                        }) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .frame(height: 60)
                    .background(Color.yellow)
                }
                .opacity(viewModel.isFullScreen ? 0 : 1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isFullScreen)
        .statusBar(hidden: viewModel.isFullScreen) // 全屏时隐藏状态栏
    }
}

// MARK: - 预览
struct SwiftUIPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIPlayerView()
            .environmentObject(PlayerViewModel())
    }
} 
