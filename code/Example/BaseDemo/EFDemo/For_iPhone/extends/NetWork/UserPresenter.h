//
//  UserPresenter.h
//  EFExtend
//
//  Created by mac on 16/3/24.
//  Copyright © 2016年 Eric. All rights reserved.
//



@interface UserPresenter : Presenter

#pragma mark login
AS_STRING(login)
AS_STRING(loginIO_username)
AS_STRING(loginIO_password)
AS_STRING(loginIO_force)
AS_STRING(loginIO_app)
AS_STRING(loginIO_uuid)
AS_STRING(loginIO_platform)

#pragma mark DownVideo
AS_STRING(DownVideo)
AS_STRING(DownVideoIO_url)

@end
