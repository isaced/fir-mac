//
//  MainViewController.swift
//  fir-mac
//
//  Created by isaced on 16/6/22.
//
//

import Cocoa

class MainViewController: NSSplitViewController {
    
    @IBOutlet weak var splitLeftItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let visualEffectView = NSVisualEffectView(frame: NSMakeRect(0, 0, 0, 0))//<---the width and height is set to 0, as this doesn't matter.
        visualEffectView.material = .appearanceBased//Dark,MediumLight,PopOver,UltraDark,AppearanceBased,Titlebar,Menu
        visualEffectView.blendingMode = .behindWindow//I think if you set this to WithinWindow you get the effect safari has in its TitleBar. It should have an Opaque background behind it or else it will not work well
        visualEffectView.state = .active//FollowsWindowActiveState,Inactive
        self.splitLeftItem.viewController.view = visualEffectView/*you can also add the visualEffectView to the contentview, just add some width and height to the visualEffectView, you also need to flip the view if you like to work from TopLeft, do this through subclassing*/
    }
}
