import AppKit

class CustomSwitch: NSControl {
    
    var isOn: Bool = true {
        didSet {
            updateAppearance()
        }
    }
    
    var onColor: NSColor = .systemBlue
    var offColor: NSColor = .systemGray.withAlphaComponent(0.5)
    var thumbColor: NSColor = .white
    
    private let trackView = NSView()
    private let thumbView = NSView()
    
    private let trackHeight: CGFloat = 18
    private let trackWidth: CGFloat = 32
    private let thumbSize: CGFloat = 14
    private let cornerRadius: CGFloat = 9
    private let thumbPadding: CGFloat = 2
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        
        trackView.wantsLayer = true
        trackView.layer?.cornerRadius = cornerRadius
        trackView.layer?.masksToBounds = true
        addSubview(trackView)
        
        thumbView.wantsLayer = true
        thumbView.layer?.cornerRadius = thumbSize / 2
        thumbView.layer?.masksToBounds = false
        thumbView.layer?.shadowColor = NSColor.black.cgColor
        thumbView.layer?.shadowOffset = CGSize(width: 0, height: -1)
        thumbView.layer?.shadowOpacity = 0.15
        thumbView.layer?.shadowRadius = 1
        addSubview(thumbView)
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(clickGesture)
        
        updateAppearance()
    }
    
    override func layout() {
        super.layout()
        
        trackView.frame = NSRect(x: 0, y: 0, width: trackWidth, height: trackHeight)
        
        let thumbX = isOn ? trackWidth - thumbSize - thumbPadding : thumbPadding
        thumbView.frame = NSRect(x: thumbX, y: thumbPadding, width: thumbSize, height: thumbSize)
    }
    
    @objc private func handleClick() {
        isOn.toggle()
        animateThumb()
        
        if let action = action, let target = target {
            _ = target.perform(action, with: self)
        }
    }
    
    private func animateThumb() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            let thumbX = isOn ? trackWidth - thumbSize - thumbPadding : thumbPadding
            thumbView.animator().frame.origin.x = thumbX
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            trackView.layer?.backgroundColor = isOn ? onColor.cgColor : offColor.cgColor
        }
    }
    
    private func updateAppearance() {
        trackView.layer?.backgroundColor = isOn ? onColor.cgColor : offColor.cgColor
        thumbView.layer?.backgroundColor = thumbColor.cgColor
        needsLayout = true
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: trackWidth, height: trackHeight)
    }
}
