//
//  MenubarExtraView.swift
//  highpitch
//
//  Created by yuncoffee on 10/10/23.
//

#if os(macOS)
import SwiftUI
import SwiftData

struct MenubarExtraView: View {
    @Environment(\.openWindow)
    private var openWindow
    
    // MARK: - AppleScript Remove
    @Environment(MediaManager.self)
    private var mediaManager
    @Environment(ProjectManager.self)
    private var projectManager
    
    @Environment(\.modelContext)
    var modelContext
    @Query(sort: \ProjectModel.creatAt)
    var projectModels: [ProjectModel]
    @State
    private var isRecording = false
    
    @Binding
    var refreshable: Bool
    @Binding
    var selectedProject: ProjectModel?
    
    var body: some View {
        ZStack {
            Text("  ")
                .frame(width: 45, height: 1)
                .popover(isPresented: $isRecording, arrowEdge: .bottom) {
                    let message = mediaManager.isRecording ? "연습 녹음이 시작되었어요!" : "연습 녹음 저장이 완료되었어요!"
                    Text("\(message)")
                        .padding()
                }
                .frame(alignment: .center)
            VStack(spacing: 0) {
                MenubarExtraHeader(
                    selectedProject: $selectedProject,
                    isRecording: $isRecording
                )
                MenubarExtraContent(selectedProject: $selectedProject)
                if projectManager.current != nil {
                    MenubarExtraFooter(selectedProject: $selectedProject)
                }
            }
            .frame(
                width: isRecording ? 0 : 400,
                height: isRecording ? 0 : 440,
                alignment: .top
            )
            .background(Color.HPComponent.Detail.background)
        }
        .frame(alignment: .top)
        .onChange(of: mediaManager.isRecording) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isRecording = true
            }
        }
        .onDisappear {
            refreshable = false
        }
    }
}

// #Preview {
//    return MenubarExtraView()
//        .environment(AppleScriptManager())
//        .environment(MediaManager())
//        .environment(KeynoteManager())
//        .frame(maxWidth: 360, maxHeight: 480)
// }
#endif
