//
//  FloatingPanelController.swift
//  highpitch
//
//  Created by 이재혁 on 11/13/23.
//

import SwiftUI

class PanelController: NSWindowController {
    var panel: NSPanel?
    
    init(xpos: Int, ypos: Int, width: Int, height: Int) {
        let panel = NSPanel(
            contentRect: NSRect(x: xpos, y: ypos, width: width, height: height),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        
        panel.backgroundColor = NSColor(.clear)
        panel.level = .mainMenu
        panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        panel.orderFrontRegardless()
        panel.isMovableByWindowBackground = true
        
        super.init(window: panel)
        self.panel = panel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showPanel(_ sender: Any?) {
        self.panel?.makeKeyAndOrderFront(sender)
    }
    
    func hidePanel(_ sender: Any?) {
        self.panel?.orderOut(sender)
    }
    
    func getPanelPosition() -> NSPoint? {
        print(panel?.accessibilityActivationPoint().x)
        return panel?.accessibilityActivationPoint()
    }
    
}
