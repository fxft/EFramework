//
//  UserPresenter.h
//  JJICar
//
//  Created by mac on 15/12/2.
//  Copyright © 2015年 mac. All rights reserved.
//



@interface YCUserPresenter : Presenter

#pragma mark - ===========prit===========   login
#pragma mark login
AS_STRING(login)

#pragma mark - ===========prit===========   regist
#pragma mark regist
AS_STRING(regist)

#pragma mark - ===========prit===========   regist
#pragma mark regist
AS_STRING(sendRegSmsCode)

#pragma mark - ===========prit===========   forgetPassword
#pragma mark forgetPassword
AS_STRING(forgetPassword)

#pragma mark - ===========prit===========   smsLogin
#pragma mark smsLogin
AS_STRING(smsLogin)

#pragma mark - ===========prit===========   getProfile
#pragma mark getProfile
AS_STRING(getProfile)

#pragma mark - ===========prit===========   getMerchantList
#pragma mark getMerchantList
AS_STRING(getMerchantList)

#pragma mark - ===========prit===========   getMerchantInfo
#pragma mark getMerchantInfo
AS_STRING(getMerchantInfo)

#pragma mark - ===========prit===========   packageDetailInfo
#pragma mark packageDetailInfo
AS_STRING(packageDetailInfo)





//-------------------------------------------------------------------------------
#pragma mark - ===========prit===========   automationLogin
#pragma mark automationLogin
AS_STRING(automationLogin)

#pragma mark - ===========prit===========   getInviteInfo
#pragma mark getInviteInfo
AS_STRING(getInviteInfo)

#pragma mark - ===========prit===========   changeNickname
#pragma mark changeNickname
AS_STRING(changeNickname)
AS_STRING(changeNicknameIO_newNickname)

#pragma mark - ===========prit===========   changeUserPSW
#pragma mark changeUserPSW
AS_STRING(changeUserPSW)
AS_STRING(changePasswordIO_oldPassword)
AS_STRING(changePasswordIO_newPassword)
AS_STRING(changePasswordIO_renewPassword)

#pragma mark - ===========prit===========   uploadHeadImage
#pragma mark uploadHeadImage
AS_STRING(uploadHeadImage)

#pragma mark - ===========prit===========   getInComeInfo
#pragma mark getInComeInfo
AS_STRING(getInComeInfo)

#pragma mark - ===========prit===========   getMessage
#pragma mark getMessage
AS_STRING(getMessage)

#pragma mark - ===========prit===========   getIntegralOperationList
#pragma mark getIntegralOperationList
AS_STRING(getIntegralOperationList)

#pragma mark - ===========prit===========   getGoldOperationList
#pragma mark getGoldOperationList
AS_STRING(getGoldOperationList)

#pragma mark - ===========prit===========    getComsumptionVolums
#pragma mark getComsumptionVolums
AS_STRING(getComsumptionVolums)

#pragma mark - ===========prit===========    getCouponVolumes
#pragma mark getCouponVolumes
AS_STRING(getCouponVolumes)

#pragma mark - ===========prit===========    cancelVolume
#pragma mark cancelVolume
AS_STRING(cancelVolume)

#pragma mark - ===========prit===========    getOrderList
#pragma mark getOrderList
AS_STRING(getOrderList)

#pragma mark - ===========prit===========    getPackageList
#pragma mark getPackageList
AS_STRING(getPackageList)


@end
