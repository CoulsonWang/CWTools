//
//  CWQRTool.swift
//  二维码工具类
//
//  Created by Coulson_Wang on 2017/7/17.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

import UIKit
import AVFoundation

typealias CWScanResultBlock = ([String]) -> ()

enum CWQRInputCorrectionLevel: String {
    case low = "L"
    case middle = "M"
    case quality = "Q"
    case hight = "H"
}

enum CWQRImageQualityLevel: CGFloat {
    case veryLow = 1
    case low = 5
    case normal = 10
    case middle = 20
    case high = 40
    case veryHight = 80
}

class CWQRTool: NSObject {
    /// 单例
    static let shareInstance = CWQRTool()
    
    // MARK:- 生成二维码的参数:
    
    /// 二维码纠错率，默认为"M"
    var inputCorrectionLevel: CWQRInputCorrectionLevel?
    /// 生成的二维码图片的质量
    var QRQuality: CWQRImageQualityLevel?
    /// 前景图片占据整个二维码图片的比例
    var imageScale: CGFloat?
    
    
    // MARK:- 二维码边框的参数:
    
    /// 二维码的边框颜色
    var borderColor: UIColor?
    /// 二维码的边框线条宽度
    var borderLineWidth: CGFloat?
    
    
    // MARK:- 扫描二维码用到的工具属性
    /// 输入对象
    fileprivate lazy var input: AVCaptureDeviceInput? = {
        // 设置输入
        // 获取摄像头设备
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // 把摄像头设备当做输入设备
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            print(error)
            return nil
        }
    }()
    
    /// 输出对象
    fileprivate lazy var output: AVCaptureMetadataOutput = {
        // 设置输出
        let output = AVCaptureMetadataOutput()
        // 设置结果处理的代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }()
    
    /// 会话属性
    fileprivate lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    
    /// 视频展示层，显示摄像头的画面
    fileprivate lazy var layer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer!
    }()
    
    /// 扫描完成后的回调
    fileprivate var scanResultBlock: ScanResultBlock?
    /// 是否需要把二维码绘制出来
    fileprivate var isDrawFrame: Bool = false
    
    
    
    }


// MARK:- 核心方法:
extension CWQRTool {
    
    /// 生成二维码
    ///
    /// - Parameters:
    ///   - inputStr: 二维码信息字符串
    ///   - centerImage: 中间显示的图片
    /// - Returns: 二维码图片
    func generatorQRCode(_ inputStr: String, centerImage: UIImage?) -> UIImage {
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setDefaults()
        
        let data = inputStr.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 设置二维码的纠错率，默认为M
        let correctionLevel: String = inputCorrectionLevel?.rawValue ?? "M"
        filter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        var image = filter?.outputImage
        
        
        // 处理成为图片尺寸
        let scale: CGFloat = QRQuality?.rawValue ?? 20
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        image = image?.applying(transform)
        
        var resultImage = UIImage(ciImage: image!)
        
        // 添加前景图片
        if centerImage != nil {
            let centerScale = imageScale ?? 0.3
            resultImage = getNewImage(resultImage, center: centerImage!, centerScale: centerScale)
        }
        
        return resultImage
    }
    
    /// 检测二维码
    ///
    /// - Parameters:
    ///   - image: 原始图片
    ///   - isDrawQRCodeFrame: 是否需要绘制边框
    /// - Returns: 元组，第一个元素是检测到的所有信息数组，第二个元素为绘制边框后的图片
    func detectorQRCodeImage(_ image: UIImage, isDrawQRCodeBorder: Bool) -> (resultStrs: [String]?, resultImage: UIImage) {
        
        let imageCI = CIImage(image: image)
        
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        // 探测二维码特征
        let features = dector?.features(in: imageCI!)
        
        // 临时图片
        var resultImage = image
        
        var result = [String]()
        for feature in features! {
            let qrFeature = feature as! CIQRCodeFeature
            result.append(qrFeature.messageString!)
            // 仅当传入参数为true时才进行回执
            if isDrawQRCodeBorder {
                let pathColor: UIColor = borderColor ?? UIColor.red
                let lineWidth: CGFloat = borderLineWidth ?? 6.0
                resultImage = drawFrame(resultImage, feature: qrFeature, pathColor: pathColor, lineWidth: lineWidth)
            }
        }
        
        return (result, resultImage)
        
    }
    
    /// 设置扫描二维码时的有效区域
    ///
    /// - Parameter orignRect: 有效区域
    func setRectInterest(_ orignRect: CGRect) -> () {

        let bounds = UIScreen.main.bounds
        let x: CGFloat = orignRect.origin.x / bounds.size.width
        let y: CGFloat = orignRect.origin.y / bounds.size.height
        let width: CGFloat = orignRect.size.width / bounds.size.width
        let height: CGFloat = orignRect.size.height / bounds.size.height
        output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
    }
    
    /// 扫描二维码
    ///
    /// - Parameters:
    ///   - inView: 显示预览视图的view
    ///   - isDrawFrame: 是否需要绘制边框
    ///   - resultBlock: 扫描成功时的回调
    func scanQRCode(_ inView: UIView, isDrawFrame: Bool, resultBlock: @escaping (_ resultStrs: [String])->()) {
        
        // 记录闭包
        scanResultBlock = resultBlock
        self.isDrawFrame = isDrawFrame
        
        if session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
        }else {
            return
        }
        
        // 设置二维码可以识别的码制
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 添加视频预览图层
        if inView.layer.sublayers == nil {
            layer.frame = inView.layer.bounds
            inView.layer.insertSublayer(layer, at: 0)
        }else {
            let subLayers = inView.layer.sublayers!
            if  !subLayers.contains(layer) {
                layer.frame = inView.layer.bounds
                inView.layer.insertSublayer(layer, at: 0)
            }
        }
        
        session.startRunning()
    }
}

// MARK:- 私有方法
extension CWQRTool {
    /// 生成包含前景图片的二维码图片
    fileprivate func getNewImage(_ sourceImage: UIImage, center: UIImage, centerScale: CGFloat) -> UIImage {
        
        if centerScale >= 1.0 || centerScale <= 0 {
            return sourceImage
        }
        
        let size = sourceImage.size

        UIGraphicsBeginImageContext(size)
        
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let width: CGFloat = size.width * centerScale
        let height: CGFloat = size.height * centerScale
        let x: CGFloat = (size.width - width) * 0.5
        let y: CGFloat = (size.height - height) * 0.5
        center.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    /// 根据检测结果，给二维码绘制边框
    fileprivate func drawFrame(_ image: UIImage, feature: CIQRCodeFeature, pathColor: UIColor, lineWidth: CGFloat) -> UIImage {
        
        let size = image.size

        UIGraphicsBeginImageContext(size)
        
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 转换坐标系(上下颠倒)
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        
        // 绘制路径
        let bounds = feature.bounds
        let path = UIBezierPath(rect: bounds)
        pathColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    /// 移除已经绘制的边框
    fileprivate func  removeFrameLayer() -> () {
        guard let subLayers = layer.sublayers else {return}
        
        for subLayer in subLayers {
            if subLayer.isKind(of: CAShapeLayer.self)
            {
                subLayer.removeFromSuperlayer()
            }
        }
    }
    
    /// 在视频预览层绘制二维码边框
    fileprivate func drawFrame(_ qrCodeObj: AVMetadataMachineReadableCodeObject, pathColor: CGColor, lineWidth: CGFloat) -> () {
        
        let corners = qrCodeObj.corners
        
        // 借助一个图形层, 来绘制
        let shapLayer = CAShapeLayer()
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = pathColor
        shapLayer.lineWidth = lineWidth
        
        // 根据四个点, 创建一个路径
        let path = UIBezierPath()
        var index = 0
        for corner in corners! {
            
            let pointDic = corner as! CFDictionary
            let point = CGPoint(dictionaryRepresentation: pointDic)
        
            if index == 0 {
                path.move(to: point!)
            }else {
                path.addLine(to: point!)
            }
            index += 1
        }
        // 闭合路径
        path.close()
        
        // 3. 给图形图层的路径赋值, 代表, 图层展示怎样的形状
        shapLayer.path = path.cgPath
        
        
        
        // 4. 直接添加图形图层到需要展示的图层
        layer.addSublayer(shapLayer)
        
        
    }

}


// MARK:- 扫描到结果的代理方法
extension CWQRTool: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if isDrawFrame {
            removeFrameLayer()
        }

        var resultStrs = [String]()
        for obj in metadataObjects {
            if (obj as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self)
            {
                // 转换成为, 二维码, 在预览图层上的真正坐标
                // qrCodeObj.corners 代表二维码的四个角, 但是, 需要借助视频预览 图层,转换成为,我们需要的可以用的坐标
                let resultObj = layer.transformedMetadataObject(for: obj as! AVMetadataObject)
                
                let qrCodeObj = resultObj as! AVMetadataMachineReadableCodeObject
                
                resultStrs.append(qrCodeObj.stringValue)

                if isDrawFrame {
                    let pathColor: CGColor = (borderColor ?? UIColor.red) as! CGColor
                    let lineWidth: CGFloat = borderLineWidth ?? 6.0
                    drawFrame(qrCodeObj, pathColor: pathColor, lineWidth: lineWidth)
                }
                
            }
        }
        if scanResultBlock != nil {
            scanResultBlock!(resultStrs)
        }
    }
}
