  EFFramework 是一个Ios快速开发框架，吸收了BeeFramework的核心精髓(其实是抄袭^_^)，Three20的控件体系，汇聚了各类github上常用的框架、控件；

   对阿里巴巴开源的Weex进行了支持  

注意：由于WeexSDK依赖于开源框架SocketRocket，如果EFTRLib的工程需要重新编译时，请在Pods工程中找到WeexSDK，并在Frameworks Search Paths添加$(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/SocketRocket