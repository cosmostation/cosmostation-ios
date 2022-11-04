//
//  AllValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class AllValidatorCell: UITableViewCell {

    @IBOutlet weak var votingPowerTitleLabel: UILabel!
    @IBOutlet weak var estAprTitleLabel: UILabel!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var validatorImg: UIImageView!
    @IBOutlet weak var revokedImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var bandOracleOffImg: UIImageView!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        validatorImg.layer.borderWidth = 1
        validatorImg.layer.masksToBounds = false
        validatorImg.layer.borderColor = UIColor.font04.cgColor
        validatorImg.layer.cornerRadius = validatorImg.frame.height/2
        validatorImg.clipsToBounds = true
        
        self.selectionStyle = .none
        
        powerLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        commissionLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        votingPowerTitleLabel.text = NSLocalizedString("str_voting_power", comment: "")
        estAprTitleLabel.text = NSLocalizedString("str_est_apr", comment: "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.validatorImg.image = UIImage(named: "validatorDefault")
        self.monikerLabel.text = "-"
        self.powerLabel.text = "-"
        self.commissionLabel.text = "-"
        self.bandOracleOffImg.isHidden = true
    }
    
    func updateView(_ validator: Cosmos_Staking_V1beta1_Validator, _ chainConfig: ChainConfig?) {
        if (chainConfig == nil) { return }
        let chainType = chainConfig!.chainType
        powerLabel.attributedText =  WDP.dpAmount(validator.tokens, powerLabel.font, chainConfig!.divideDecimal, 6)
        commissionLabel.attributedText = WUtils.getDpEstAprCommission(commissionLabel.font, NSDecimalNumber.init(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -18), chainType)
        if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operatorAddress)) {
            validatorImg.af_setImage(withURL: url)
        }
        
        monikerLabel.text = validator.description_p.moniker
        monikerLabel.adjustsFontSizeToFitWidth = true
        
        if (validator.jailed == true) {
            revokedImg.isHidden = false
            validatorImg.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            revokedImg.isHidden = true
            validatorImg.layer.borderColor = UIColor.font04.cgColor
        }
        if BaseData.instance.mMyValidators_gRPC.first(where: {$0.operatorAddress == validator.operatorAddress}) != nil {
            cardView.backgroundColor = chainConfig?.chainColorBG
            
        } else {
            cardView.backgroundColor = UIColor.cardBg
        }
        
        
        //display for band oracle status
        if (chainType == ChainType.BAND_MAIN) {
            if (BaseData.instance.mParam?.params?.band_active_validators?.addresses.contains(validator.operatorAddress) == false) {
                bandOracleOffImg.isHidden = false
            }
        }
        
        //temp hide apr for no mint param chain
        if (chainType == ChainType.ALTHEA_TEST) {
            commissionLabel.text = "--"
        }
    }
    
    
    func addRippleEffect(to referenceView: UIView) {
        /*! Creates a circular path around the view*/
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: referenceView.bounds.size.height))
        /*! Position where the shape layer should be */
        let shapePosition = CGPoint(x: referenceView.bounds.size.width / 2.0, y: referenceView.bounds.size.height / 2.0)
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: referenceView.bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = UIColor.white.cgColor
        rippleShape.lineWidth = 4
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        
        /*! Add the ripple layer as the sublayer of the reference view */
        referenceView.layer.addSublayer(rippleShape)
        /*! Create scale animation of the ripples */
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
        /*! Create animation for opacity of the ripples */
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        /*! Group the opacity and scale animations */
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = CFTimeInterval(0.7)
        animation.repeatCount = 25
        animation.isRemovedOnCompletion = true
        rippleShape.add(animation, forKey: "rippleEffect")
    }
    
}
