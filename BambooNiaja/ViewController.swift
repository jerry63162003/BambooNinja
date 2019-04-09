//
//  ViewController.swift
//  BambooNiaja
//
//  Created by user04 on 2019/4/9.
//  Copyright © 2019年 jerryHU. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    let gameConfig = GameConfig()
    
    lazy var settingView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear

        let alphaView = UIView()
        alphaView.backgroundColor = UIColor.black
        alphaView.alpha = 0.8
        bgView.addSubview(alphaView)
        alphaView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(bgView)
        }

        let bgImage = UIImageView(image:#imageLiteral(resourceName: "设置弹窗"))
        bgImage.isUserInteractionEnabled = true
        bgView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.center.equalTo(bgView)
        }

        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "叉"), for: .normal)
        cancelButton.tag = 31
        cancelButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        bgView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints({ (make) in
            make.top.equalTo(bgImage).offset(28)
            make.left.equalTo(bgImage.snp.right).offset(-62)
        })

        let labelMusic = UILabel()
        labelMusic.textColor = UIColor.black
        labelMusic.text = "音乐"
        labelMusic.font = UIFont.systemFont(ofSize: 21)
        bgImage.addSubview(labelMusic)
        labelMusic.snp.makeConstraints({ (make) in
            make.centerX.equalTo(bgImage)
            make.centerY.equalTo(bgImage).offset(-50)
        })
        
        let musicButton = UIButton()
        musicButton.isSelected = gameConfig.isGameMusic
        musicButton.setImage(#imageLiteral(resourceName: "ON"), for: .selected)
        musicButton.setImage(#imageLiteral(resourceName: "off"), for: .normal)
        musicButton.tag = 10
        musicButton.addTarget(self, action: #selector(settingClick(_:)), for: .touchUpInside)
        bgImage.addSubview(musicButton)
        musicButton.snp.makeConstraints({ (make) in
            make.centerX.equalTo(labelMusic)
            make.top.equalTo(labelMusic.snp.bottom).offset(20)
        })
        
        let labelEffect = UILabel()
        labelEffect.textColor = UIColor.black
        labelEffect.text = "音效"
        labelEffect.font = UIFont.systemFont(ofSize: 21)
        bgImage.addSubview(labelEffect)
        labelEffect.snp.makeConstraints({ (make) in
            make.centerX.equalTo(labelMusic)
            make.top.equalTo(musicButton.snp.bottom).offset(20)
        })
        
        let soundButton = UIButton()
        soundButton.isSelected = gameConfig.isGameSound
        soundButton.setImage(#imageLiteral(resourceName: "ON"), for: .selected)
        soundButton.setImage(#imageLiteral(resourceName: "off"), for: .normal)
        soundButton.tag = 11
        soundButton.addTarget(self, action: #selector(settingClick(_:)), for: .touchUpInside)
        bgImage.addSubview(soundButton)
        soundButton.snp.makeConstraints({ (make) in
            make.centerX.equalTo((labelMusic))
            make.top.equalTo(labelEffect.snp.bottom).offset(20)
        })
        
        return bgView
    }()

    lazy var informationView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear

        let alphaView = UIView()
        alphaView.backgroundColor = UIColor.black
        alphaView.alpha = 0.8
        bgView.addSubview(alphaView)
        alphaView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(bgView)
        }

        let bgImage = UIImageView(image:#imageLiteral(resourceName: "玩法说明弹窗"))
        bgImage.isUserInteractionEnabled = true
        bgView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.center.equalTo(bgView)
        }

        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "叉"), for: .normal)
        cancelButton.tag = 32
        cancelButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        bgView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints({ (make) in
            make.top.equalTo(bgImage).offset(28)
            make.left.equalTo(bgImage.snp.right).offset(-62)
        })

        let arr = ["1、手指触碰屏幕任意区域，触碰时间越长杆子越长","2、前方平台为目的地","3、平台中央的红色区域为杆子最佳着陆点，触碰此处加分", "4、杆子太长或者太短都会使游戏结束哦"]
        for i in 0..<arr.count{
            let label1 = UILabel()
            label1.textColor = UIColor(red:0.05, green:0.32, blue:0.59, alpha:1.0)
            label1.font = UIFont.systemFont(ofSize: 14)
            label1.text = arr[i]
            label1.adjustsFontSizeToFitWidth = true
            label1.numberOfLines = 0
            bgView.addSubview(label1)
            label1.snp.makeConstraints({ (make) in
                make.centerX.equalTo(bgImage)
                make.top.equalTo(bgImage).offset(90 + i * 180 / arr.count)
                make.width.equalTo(143)
                make.height.equalTo(180 / arr.count)
            })
        }

        return bgView
    }()

    override func viewWillAppear(_ animated: Bool) {
        setMainBgImage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonClick(_ sender: UIButton) {


        if sender.tag == 10 {
            openInformation()
        }

        if sender.tag == 12 {
            openSetting()
        }

        if sender.tag == 13 {
            let gameViewController = GameViewController()
            self.present(gameViewController, animated: true, completion: nil)
        }
        
        if sender.tag == 31 {
            settingView.removeFromSuperview()
        }

        if sender.tag == 32 {
            informationView.removeFromSuperview()
        }
    }
    
    @objc func settingClick(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.tag == 10 {
            //音樂
            gameConfig.isGameMusic = sender.isSelected
        }
        if sender.tag == 11 {
            //音效
            gameConfig.isGameSound = sender.isSelected
        }
    }
    
    func setMainBgImage() {
        let bgImageView = UIImageView(image:#imageLiteral(resourceName: "首页"))
        view.addSubview(bgImageView)
        bgImageView.snp.makeConstraints({ (make) in
            make.left.right.top.bottom.equalTo(view)
        })
        
        let settingBtn = UIButton()
        settingBtn.setImage(#imageLiteral(resourceName: "设置"), for: .normal)
        settingBtn.tag = 12
        settingBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(settingBtn)
        settingBtn.snp.makeConstraints({ (make) in
            make.top.equalTo(bgImageView).offset(50)
            make.right.equalTo(bgImageView).offset(-30)
        })
        
        let imformationBtn = UIButton()
        imformationBtn.setImage(#imageLiteral(resourceName: "玩法说明按钮"), for: .normal)
        imformationBtn.tag = 10
        imformationBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(imformationBtn)
        imformationBtn.snp.makeConstraints({ (make) in
            make.center.equalTo(bgImageView)
        })
        
        let playBtn = UIButton()
        playBtn.setImage(#imageLiteral(resourceName: "开始游戏"), for: .normal)
        playBtn.tag = 13
        playBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(playBtn)
        playBtn.snp.makeConstraints({ (make) in
            make.top.equalTo(imformationBtn.snp.bottom).offset(20)
            make.centerX.equalTo(imformationBtn)
        })

    }

    func openInformation() {
        view.addSubview(informationView)
        informationView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
    }

    func openSetting() {
        view.addSubview(settingView)
        settingView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
    }

}

