//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/10/21.
//

import Foundation

struct CGConstants {
    static let CG_PIP_DATE = "cg_pip_date"
    static let CG_PIP_VID_SYNC_DATA = "cg-pip-vid-sync"
    static let ERROR = "CUSTOMERGLU Error:"
    static let JSON_ERROR = "CUSTOMERGLU: json parsing error:"
    static let CUSTOMERGLU_TOKEN = "CustomerGlu_Token_Encrypt"
    static let CUSTOMERGLU_USERID = "CustomerGlu_user_id_Encrypt"
    static let CUSTOMERGLU_IS_ANONYMOUS_USER = "CustomerGlu_is_anonymous_user"
    static let CUSTOMERGLU_LIGHT_LOTTIE_FILE_PATH = "CustomerGlu_Light_Lottiepath"
    static let CUSTOMERGLU_DARK_LOTTIE_FILE_PATH = "CustomerGlu_Dark_Lottiepath"
    static let CUSTOMERGLU_LIGHT_EMBEDLOTTIE_FILE_PATH = "CustomerGlu_Light_Embed_Lottiepath"
    static let CUSTOMERGLU_DARK_EMBEDLOTTIE_FILE_PATH = "CustomerGlu_Dark_Embed_Lottiepath"
    static let CUSTOMERGLU_PIP_PATH = "CustomerGlu_PiP_VideoPath"
    static let DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let Analitics_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let MIDDLE_NOTIFICATIONS = "middle-default"
    static let FULL_SCREEN_NOTIFICATION = "full-default"
    static let BOTTOM_SHEET_NOTIFICATION = "bottom-slider"
    static let BOTTOM_DEFAULT_NOTIFICATION = "bottom-default"
    static let MIDDLE_NOTIFICATIONS_POPUP = "middle-popup"
    static let BOTTOM_DEFAULT_NOTIFICATION_POPUP     = "bottom-popup"
    static let FCM_APN = "fcm_apn"
    static let CustomerGluCrash = "CustomerGluCrash_Encrypt"
    static let CustomerGluPopupDict = "CustomerGluPopupDict_Encrypt"
    static let CUSTOMERGLU_ANONYMOUSID = "CustomerGluAnonymousId_Encrypt"
    static let CUSTOMERGLU_USERDATA = "CustomerGluUserData_Encrypt"
    
    
    static let CUSTOMERGLU_TOKEN_OLD = "CustomerGlu_Token"
    static let CUSTOMERGLU_USERID_OLD = "CustomerGlu_user_id"
    static let CustomerGluCrash_OLD = "CustomerGluCrash"
    static let CustomerGluPopupDict_OLD = "CustomerGluPopupDict"
    
    static let default_whitelist_doamin = "customerglu.com"
    static var default_redirect_url = "https://constellation.customerglu.com/error.html"
    static let customerglu_encryptedKey = "customerglu_encryptedKey"
    static let CGOPENWALLET = "CG-OPEN-WALLET"
    static let CGSENTRYDSN = "https://d856e4a14b6d4c6eae1fc283d6ddbe8e@o4504440824856576.ingest.sentry.io/4504442660454400"
    static let MQTT_Identifier = "MQTT_Identifier"
    static let MQTT_ENTRYPOINTS = "ENTRYPOINT"
    static let MQTT_CLIENT_TESTING = "OPEN_CLIENT_TESTING_PAGE"
    static let CG_SAFE_AREA_DEFAULT = -1
    
    static let ENTRY_POINT_DISMISS = "ENTRY_POINT_DISMISS"
    static let ENTRY_POINT_CLICK = "ENTRY_POINT_CLICK"
    static let ENTRY_POINT_LOAD = "ENTRY_POINT_LOAD"
    static let PIP_ENTRY_POINT_DISMISS = "PIP_ENTRY_POINT_DISMISS"
    static let PIP_ENTRY_POINT_CLICK = "PIP_ENTRY_POINT_CLICK"
    static let PIP_ENTRY_POINT_LOAD = "PIP_ENTRY_POINT_LOAD"
    static let PIP_ENTRY_POINT_CTA_CLICK = "PIP_ENTRY_POINT_CTA_CLICK"
    static let MUTE_PIP_VIDEO = "MUTE_PIP_VIDEO"
    static let UNMUTE_PIP_VIDEO = "UNMUTE_PIP_VIDEO"
    static let EXPAND_PIP_VIDEO = "EXPAND_PIP_VIDEO"
    static let COLLAPSE_PIP_VIDEO = "COLLAPSE_PIP_VIDEO"
    static let PIP_VIDEO_25_COMPLETED = "PIP_VIDEO_25_COMPLETED"
    static let PIP_VIDEO_75_COMPLETED = "PIP_VIDEO_75_COMPLETED"
    static let PIP_VIDEO_50_COMPLETED = "PIP_VIDEO_50_COMPLETED"
    static let PIP_VIDEO_COMPLETED = "PIP_VIDEO_COMPLETED"
    static let MQTT_Enabled_Components_State_Sync = "STATE_SYNC"
    static let MQTT_Enabled_Components_Nudges = "NUDGES"
    static let MQTT_Enabled_Components_EntryPoints = "ENTRYPOINTS"
    
    static let clientSSLCertificateAsStringKey = "clientSSLCertificateAsStringKey"
    static let remoteSSLCertificateAsStringKey = "remoteSSLCertificateAsStringKey"
    static let CGGetProgramResponse = "CGGetProgramResponse"
    static let CGGetRewardResponse = "CGGetRewardResponse"
    static let allCampaignsIdsAsString = "allCampaignsIdsAsString"
    static let ad_pop_up_response = "{\n" +
   "    \"_id\": \"66bc8c5035d9121437800b1a\",\n" +
   "    \"name\": \"default title\",\n" +
   "    \"client\": \"84acf2ac-b2e0-4927-8653-cba2b83816c2\",\n" +
   "    \"consumer\": \"MOBILE\",\n" +
   "    \"status\": \"ACTIVE\",\n" +
   "    \"visible\": true,\n" +
   "    \"triggerType\": \"STATIC\",\n" +
   "    \"availability\": \"FOREVER\",\n" +
   "    \"mobile\": {\n" +
   "        \"container\": {\n" +
   "            \"android\": {\n" +
   "                \"allowedActitivityList\": [\n" +
   "                    \"HomeScreen\"\n" +
   "                ],\n" +
   "                \"disallowedActitivityList\": []\n" +
   "            },\n" +
   "            \"ios\": {\n" +
   "                \"allowedActitivityList\": [\n" +
   "                    \"HomeScreen\"\n" +
   "                ],\n" +
   "                \"disallowedActitivityList\": []\n" +
   "            },\n" +
   "            \"type\": \"AD_POPUP\",\n" +
   "            \"bannerId\": \"bannerId\",\n" +
   "            \"height\": \"310\",\n" +
   "            \"width\": \"20\",\n" +
   "            \"position\": \"BOTTOM-RIGHT\",\n" +
   "            \"vertical_padding\": \"10\",\n" +
   "            \"horizontal_padding\": \"5\"\n" +
   "        },\n" +
   "        \"content\": [\n" +
   "            {\n" +
   "                \"removeOnCompletion\": false,\n" +
   "                \"type\": \"VIDEO\",\n" +
   "                \"url\": \"https://assets.customerglu.com/35deace8-c04f-43c3-a00b-9c06eaae7acb/cb9eaff9-0ecf-43b2-9bd1-dbdb3b71f4c7.mp4\",\n" +
   "                \"closeIcon\": \"https://assets.customerglu.com/84acf2ac-b2e0-4927-8653-cba2b83816c2/ic_close.png\",\n" +
   "                \"backgroundColor\": \"#000000\",\n" +
   "                \"backgroundImage\": \"https://assets.customerglu.com/84acf2ac-b2e0-4927-8653-cba2b83816c2/Group_16-removebg-preview.png\",\n" +
   "                \"campaignId\": \"62ad1c12-6be5-435a-85cc-fda72dfcac8e\",\n" +
   "                \"openLayout\": \"FULL-DEFAULT\",\n" +
   "                \"absoluteHeight\": 100,\n" +
   "                \"relativeHeight\": 60,\n" +
   "                \"closeOnDeepLink\": true,\n" +
   "                \"action\": {\n" +
   "                    \"isHandledBySDK\": false,\n" +
   "                    \"type\": \"OPEN_CAMPAIGN\",\n" +
   "                    \"url\": \"https://your-url.com\",\n" +
   "                    \"button\": {\n" +
   "                        \"showButton\": false,\n" +
   "                        \"buttonColor\": \"FFFFF\",\n" +
   "                        \"buttonText\": \"\",\n" +
   "                        \"buttonTextColor\": \"\"\n" +
   "                    }\n" +
   "                },\n" +
   "                \"primaryCta\": {\n" +
   "                    \"isHandledBySDK\": false,\n" +
   "                    \"type\": \"SHARE\",\n" +
   "                    \"url\": \"https://your-url.com\",\n" +
    "                    \"shareText\": \"Shop Now\",\n" +
    "                    \"shareImage\": \"\",\n" +
   "                    \"button\": {\n" +
   "                        \"showButton\": true,\n" +
   "                        \"buttonColor\": \"#D17842\",\n" +
   "                        \"buttonText\": \"Shop Now 😊 \",\n" +
   "                        \"buttonTextColor\": \"#000000\",\n" +
   "                        \"borderRadius\": \"20\",\n" +
   "                        \"height\": \"60\",\n" +
   "                        \"width\": \"100\",\n" +
   "                        \"textSize\": \"16\",\n" +
   "                        \"marginHorizontal\": \"16\",\n" +
   "                        \"marginVertical\": \"16\"\n" +
   "                    }\n" +
   "                },\n" +
   "                \"secondaryCta\": {\n" +
   "                    \"isHandledBySDK\": false,\n" +
   "                    \"type\": \"OPEN_CAMPAIGN\",\n" +
   "                    \"url\": \"https://your-url.com\",\n" +
   "                    \"button\": {\n" +
   "                        \"showButton\": true,\n" +
   "                        \"buttonColor\": \"#D17842\",\n" +
   "                        \"buttonText\": \"Close\",\n" +
   "                        \"buttonTextColor\": \"#000000\",\n" +
   "                        \"borderRadius\": \"20\",\n" +
   "                        \"height\": \"60\",\n" +
   "                        \"width\": \"100\",\n" +
   "                        \"textSize\": \"16\",\n" +
   "                        \"marginHorizontal\": \"16\",\n" +
   "                        \"marginVertical\": \"16\"\n" +
   "                    }\n" +
   "                    \n" +
   "                },\n" +
   "                \"_id\": \"66bc8c5035d9121437800b1c\"\n" +
   "            }\n" +
   "        ],\n" +
   "        \"conditions\": {\n" +
   "            \"delay\": 0,\n" +
   "            \"autoScroll\": true,\n" +
   "            \"autoScrollSpeed\": 5,\n" +
   "            \"draggable\": true,\n" +
   "            \"backgroundOpacity\": 0.5,\n" +
   "            \"priority\": 1,\n" +
   "            \"showCount\": {\n" +
   "                \"count\": 1000,\n" +
   "                \"dailyRefresh\": false\n" +
   "            },\n" +
   "            \"pip\": {\n" +
   "                \"muteOnDefaultPIP\": true,\n" +
   "                \"muteOnDefaultExpanded\": false,\n" +
   "                \"loopVideoPIP\": true,\n" +
   "                \"loopVideoExpanded\": false,\n" +
   "                \"darkPlayer\": false,\n" +
   "                \"removeOnDismissExpanded\": true,\n" +
   "                \"removeOnDismissPIP\": false,\n" +
   "                \"openExpandedView\": true\n" +
   "            },\n" +
   "            \"backendValidations\": \"NOT_REQUIRED\"\n" +
   "        },\n" +
   "        \"_id\": \"66bc8c5035d9121437800b1b\"\n" +
   "    },\n" +
   "    \"createdAt\": \"2024-08-14T10:52:00.501Z\",\n" +
   "    \"updatedAt\": \"2024-08-14T10:52:00.501Z\",\n" +
   "    \"__v\": 0\n" +
   "}"

}

struct CGDiagnosticConstants{
    //Diagnostics constants
    static let CG_DIAGNOSTICS_INIT_START = "CGDiagnostics - SDK Init Start"
    static let CG_DIAGNOSTICS_INIT_END = "CGDiagnostics - SDK Init End"
    static let CG_DIAGNOSTICS_USER_REGISTRATION_START = "CGDiagnostics - SDK User registration Start"
    static let CG_DIAGNOSTICS_USER_REGISTRATION_END = "CGDiagnostics - SDK User registration End"
    static let CG_DIAGNOSTICS_LOAD_CAMPAIGN_START = "CGDiagnostics - SDK User Load Campaign Start"
    static let CG_DIAGNOSTICS_LOAD_CAMPAIGN_END = "CGDiagnostics - SDK Load Campaign End"
    static let CG_DIAGNOSTICS_GET_ENTRY_POINT_START = "CGDiagnostics - SDK getEntryPoint  Start"
    static let CG_DIAGNOSTICS_GET_ENTRY_POINT_END = "CGDiagnostics - SDK getEntryPoint End"
    static let CG_DIAGNOSTICS_SEND_EVENT_START = "CGDiagnostics - SDK sendEventData Start"
    static let CG_DIAGNOSTICS_SEND_EVENT_END = "CGDiagnostics - SDK sendEventData End"
    static let CG_DIAGNOSTICS_OPEN_WALLET_CALLED = "CGDiagnostics - SDK OpenWallet Called"
    static let CG_DIAGNOSTICS_OPEN_NUDGE_CALLED = "CGDiagnostics - SDK OpenNudge Called"
    static let CG_DIAGNOSTICS_LOAD_CAMPAIGN_BY_ID_CALLED = "CGDiagnostics - SDK LoadCampaignByID Called"
    static let CG_DIAGNOSTICS_CLEAR_GLU_DATA_CALLED = "CGDiagnostics - SDK clearGluData Called"
    static let CG_DIAGNOSTICS_ENABLE_ANALYTICS_CALLED = "CGDiagnostics - SDK enableAnalyticsEvent Called"
    static let CG_DIAGNOSTICS_SET_DARK_MODE_CALLED = "CGDiagnostics - SDK setDarkMode Called"
    static let CG_DIAGNOSTICS_LISTEN_SYSTEM_DARK_MODE_CALLED = "CGDiagnostics - SDK listenToDarkMode Called"
    static let CG_DIAGNOSTICS_LOADER_COLOR_CALLED = "CGDiagnostics - SDK configureLoaderColour Called"
    static let CG_DIAGNOSTICS_CONFIGURE_SAFE_AREA_CALLED = "CGDiagnostics - SDK configureSafeArea Called"
    static let CG_DIAGNOSTICS_GLU_SDK_DEBUGGING_MODE_CALLED = "CGDiagnostics - SDK gluSDKDebuggingMode Called"
    static let CG_DIAGNOSTICS_DISABLE_SDK_CALLED = "CGDiagnostics - SDK disableGluSdk Called"
    static let CG_DIAGNOSTICS_NOTIFICATION_CALLED = "CGDiagnostics - SDK Push notification Received "
    static let CG_DIAGNOSTICS_BACKGROUND_NOTIFICATION_CALLED = "CGDiagnostics - SDK background notification Received"
    
    static let CG_DIAGNOSTICS_MQTT_ENABLED = "CGDiagnostics - MQTT Enabled"
    static let CG_DIAGNOSTICS_MQTT_DISABLED = "CGDiagnostics - MQTT Disabled"
    static let CG_DIAGNOSTICS_MQTT_INITIALIZE = "CGDiagnostics - MQTT Initialize"
    static let CG_DIAGNOSTICS_MQTT_CONNECTION_SUCCESS = "CGDiagnostics - MQTT Connection Success"
    static let CG_DIAGNOSTICS_MQTT_CONNECTION_FAILURE = "CGDiagnostics - MQTT Connection Failure"
    static let CG_DIAGNOSTICS_MQTT_SUBSCRIBE = "CGDiagnostics - MQTT Subscribe"
    static let CG_DIAGNOSTICS_MQTT_RECEIVING_MESSAGE = "CGDiagnostics - MQTT Receiving Message"
    static let CG_DIAGNOSTICS_MQTT_DISCONNECT = "CGDiagnostics - MQTT Disconnect"
    
    static let CG_DIAGNOSTICS_WEBVIEW_DIDFINISH = "CGDiagnostics - WebView Did Finish"
    static let CG_DIAGNOSTICS_WEBVIEW_START_PROVISIONAL = "CGDiagnostics - WebView Start Provisional"
    static let CG_DIAGNOSTICS_WEBVIEW_FAILED_PROVISIONAL = "CGDiagnostics - WebView Failed Provisional"
    static let CG_DIAGNOSTICS_WEBVIEW_RECEIVE_MESSAGE_FROM_WEBVIEW = "CGDiagnostics - WebView Receive Message from Webview"
    static let CG_DIAGNOSTICS_WEBVIEW_HANDLE_DEEPLINK = "CGDiagnostics - WebView Handle Deeplink"
    
    // Metrics Event
    static let CG_METRICS_SDK_READY = "CGMetrics - SDK Ready "
    static let CG_METRICS_SDK_CONFIG_CALLED = "CGMetrics - SDK Config Called"
    static let CG_METRICS_SDK_CONFIG_RESPONSE = "CGMetrics - SDK Config Response"
    static let CG_METRICS_SDK_CONFIG_SUCCESS = "CGMetrics - SDK Config Success"
    static let CG_METRICS_SDK_CONFIG_FAILURE = "CGMetrics - SDK Config Failure"
    static let CG_METRICS_SDK_REGISTER_CALLED = "CGMetrics - SDK Register Called "
    static let CG_METRICS_SDK_REGISTER_RESPONSE = "CGMetrics - SDK Register Response"
    static let CG_METRICS_SDK_REGISTER_SUCCESS = "CGMetrics - SDK Register Success"
    static let CG_METRICS_SDK_REGISTER_FAILURE = "CGMetrics - SDK Register Failure"
    static let CG_METRICS_SDK_LOAD_CAMPAIGN_CALLED = "CGMetrics - SDK Load campaign Called"
    static let CG_METRICS_SDK_LOAD_CAMPAIGN_RESPONSE = "CGMetrics - SDK Load campaign Response"
    static let CG_METRICS_SDK_LOAD_CAMPAIGN_SUCCESS = "CGMetrics - SDK Load campaign Success"
    static let CG_METRICS_SDK_LOAD_CAMPAIGN_FAILURE = "CGMetrics - SDK Load campaign Failure"
    static let CG_METRICS_SDK_ENTRY_POINTS_CALLED = "CGMetrics - SDK EntryPoints Called "
    static let CG_METRICS_SDK_ENTRY_POINTS_RESPONSE = "CGMetrics - SDK EntryPoints Response"
    static let CG_METRICS_SDK_ENTRY_POINTS_SUCCESS = "CGMetrics - SDK EntryPoints Success"
    static let CG_METRICS_SDK_ENTRY_POINTS_FAILURE = "CGMetrics - SDK EntryPoints Failure"
    static let CG_METRICS_SDK_SERVER_EVENTS_CALLED = "CGMetrics - SDK Server Events Called"
    static let CG_METRICS_SDK_SERVER_EVENTS_RESPONSE = "CGMetrics - SDK Server Events Response"
    static let CG_METRICS_SDK_SERVER_EVENTS_SUCCESS = "CGMetrics - SDK Server Events Success"
    static let CG_METRICS_SDK_SERVER_EVENTS_FAILURE = "CGMetrics - SDK Server Events Failure"
    static let CG_METRICS_SDK_WORMHOLE_CALLED = "CGMetrics - SDK Wormhole Called "
    static let CG_METRICS_SDK_WORMHOLE_RESPONSE = "CGMetrics - SDK Wormhole Response "
    static let CG_METRICS_SDK_WORMHOLE_SUCCESS = "CGMetrics - SDK Wormhole Success"
    static let CG_METRICS_SDK_WORMHOLE_FAILURE = "CGMetrics - SDK Wormhole Failure"
    
    
    static let CG_TYPE_DIAGNOSTICS = "DIAGNOSTICS"
    static let CG_TYPE_METRICS = "METRICS"
    static let CG_TYPE_CRASH = "CRASH"
    static let CG_TYPE_EXCEPTION = "EXCEPTION"
}

// Default APIParameterKey
struct APIParameterKey {
    static let deviceId = "deviceId"
    static let deviceType = "deviceType"
    static let deviceName = "deviceName"
    static let appVersion = "appVersion"
    static let isMQTTEnabled = "isMqttEnabled"
    static let writeKey = "writeKey"
    static let event_id = "event_id"
    static let event_name = "event_name"
    static let user_id = "user_id"
    static let timestamp = "timestamp"
    static let nudge = "nudge"
    static let nudge_id = "nudge_id"
    static let title = "title"
    static let body = "body"
    static let nudge_layout = "nudge_layout"
    static let click_action = "click_action"
    static let event_properties = "event_properties"
    static let userId = "userId"
    static let clientId = "clientId"
    static let customAttributes = "customAttributes"
    static let anonymousId = "anonymousId"
    static let bearer = "Bearer"
    static let apnsDeviceToken = "apnsDeviceToken"
    static let firebaseToken = "firebaseToken"
    static let campaign_id = "campaign_id"
    static let type = "type"
    static let status = "status"
    static let stack_trace = "stack_trace"
    static let method = "method"
    static let version = "version"
    static let app_name = "app_name"
    static let device_name = "device_name"
    static let os_version = "os_version"
    static let app_version = "app_version"
    static let platform = "platform"
    static let device_id = "device_id"
    static let timezone = "timezone"
    static let pageName = "pageName"
    static let nudgeType = "nudgeType"
    static let nudgeId = "nudgeId"
    static let actionName = "actionName"
    static let actionType = "actionType"
    static let actionTarget = "actionTarget"
    static let pageType = "pageType"
    static let campaignId = "campaignId"
    static let activityIdList = "activityIdList"
    static let embedIds = "embedIds"
    static let bannerIds = "bannerIds"
    static let eventId = "eventId"
    static let optionalPayload = "optionalPayload"
    static let appSessionId = "appSessionId"
    static let session_id = "session_id"
    static let userAgent = "userAgent"
    static let eventName = "eventName"
    static let cgsdkversionvalue = "3.1.6"
    static let analytics_version_value = "4.0.0"
    static let analytics_version = "analytics_version"
    static let dismiss_trigger = "dismiss_trigger"
    static let webview_content = "webview_content"
    static let webview_url = "webview_url"
    static let webview_layout = "webview_layout"
    static let absolute_height = "absolute_height"
    static let relative_height = "relative_height"
    static let platform_details = "platform_details"
    static let device_type = "device_type"
    static let os = "os"
    static let app_platform = "app_platform"
    static let sdk_version = "sdk_version"
    static let messagekey = "message"
    
    static let entry_point_data = "entry_point_data"
    static let entry_point_id = "entry_point_id"
    static let entry_point_name = "entry_point_name"
    static let entry_point_location = "entry_point_location"
    static let entry_point_container = "entry_point_container"
    static let entry_point_content = "entry_point_content"
    static let static_url = "static_url"
    static let entry_point_action = "entry_point_action"
    static let entry_point_is_expanded = "entry_point_is_expanded"
    static let action_type = "action_type"
    static let open_container = "open_container"
    static let open_content = "open_content"

}

// Default NotificationsKey
struct NotificationsKey {
    static let type = "type"
    static let customerglu = "customerglu"
    static let glu_message_type = "glu_message_type"
    static let in_app = "in-app"
    static let nudge_url = "nudge_url"
    static let page_type = "page_type"
    static let CustomerGlu = "CustomerGlu"
    static let absoluteHeight = "absoluteHeight"
    static let relativeHeight = "relativeHeight"
    static let closeOnDeepLink = "closeOnDeepLink"
}

// Default WebViewsKey
struct WebViewsKey {
    static let callback = "callback"
    static let close = "CLOSE"
    static let open_deeplink = "OPEN_DEEPLINK"
    static let open_weblink = "OPEN_WEBLINK"
    static let analytics = "ANALYTICS"
    static let share = "SHARE"
    static let updateheight = "DIMENSIONS_UPDATE"
    static let hideloader = "HIDE_LOADER"
    static let opencgwebview = "OPEN_CG_WEBVIEW"
}

// TableView Identifiers Used Throught App
struct TableViewID {
    static let BannerCell = "BannerCell"
}

// Default WebViewsKey
struct CGDismissAction {
    static let PHYSICAL_BUTTON = "PHYSICAL_BUTTON"
    static let UI_BUTTON = "UI_BUTTON"
    static let CTA_REDIRECT = "CTA_REDIRECT"
    static let SSL_FAILED = "SSL_FAILED"
    static let DEFAULT = "DEFAULT"
}

public enum TooltipPosition {
    case top, bottom
}

struct CGSafeAreaConstants {
    static let SAFE_AREA_PADDING = CGFloat(33.0)
}

