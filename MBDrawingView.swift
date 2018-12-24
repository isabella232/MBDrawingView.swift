import UIKit

public protocol MBDrawingViewDelegate {

    func drawingView(drawingView: MBDrawingView, didDrawWithPoints points: [CGPoint])

}

public class MBDrawingView: UIView {

    private var points: [CGPoint]!
    private var context: CGContext!
    private var strokeColor: UIColor = UIColor.blue.withAlphaComponent(0.75)
    private var lineWidth: CGFloat = 3

    public var delegate: MBDrawingViewDelegate?

    public convenience init(frame: CGRect, strokeColor: UIColor, lineWidth: CGFloat) {
        self.init(frame: frame)

        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    deinit {
        UIGraphicsEndImageContext()
    }

    public func setStrokeColor(strokeColor: UIColor) {
        self.strokeColor = strokeColor
        context.setStrokeColor(strokeColor.cgColor)
    }

    public func setLineWidth(lineWidth: CGFloat) {
        self.lineWidth = lineWidth
        context.setLineWidth(lineWidth)
    }

    private func setup() {
        backgroundColor = UIColor.clear
        points = [CGPoint]()

        createContext()
    }

    public func reset() {
        points = [CGPoint]()

        UIGraphicsEndImageContext();

        createContext()
    }

    private func createContext() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        context = UIGraphicsGetCurrentContext()
        setStrokeColor(strokeColor: self.strokeColor)
        setLineWidth(lineWidth: self.lineWidth)
    }

    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        points.removeAll(keepingCapacity: false)
        
        let firstPoint = touches.first!.location(in: self)
        
        points.append(firstPoint)
        context.beginPath()
        context.move(to: firstPoint)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        context.move(to: points.last!)
        
        let point = touches.first!.location(in: self)
        points.append(point)
        
        context.addLine(to: point)
        context.strokePath()
        
        #if swift(>=2.3)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        #else
        let image = UIGraphicsGetImageFromCurrentImageContext()
        #endif
        
        layer.contents = image.cgImage
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.drawingView(drawingView: self, didDrawWithPoints: points)
    }

}
