/*
 *  TSKCommonConstants.h
 *  Taskation
 *
 *  Created by Lyndsey on 9/28/08.
 *  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
 *
 */
/*
 Notification Constants
*/
#define TSK_NOTIFICATION_ACTIVITY_RECORDING @"com.lyndseyferguson.taskation.notification.activity.recording"
#define TSK_NOTIFICATION_ACTIVITY_COMPLETED @"com.lyndseyferguson.taskation.notification.activity.completed"

/*
 Dictionary Key Constants
*/
#define TSK_KEY_RECENT_FILES @"RecentFiles"
#define TSK_KEY_ACTIONS @"Actions"
#define TSK_KEY_SUBJECTS @"Subjects"
#define TSK_KEY_LICENSE @"Driver"
#define TSK_KEY_NAME @"name"
#define TSK_KEY_ACTION_SUBJECTS @"subjects"
#define TSK_KEY_SUBJECT_IDENTIFIER @"identifier"
#define TSK_KEY_ACTION_INDEX @"index"
#define TSK_KEY_SUBJECT_INDEX @"index"
#define TSK_DOCUMENT_FILENAME_EXTENSION @"taskfile"
#define TSK_KEY_LICENSE_USER @"Name"
#define TSK_KEY_LICENSE_SIGNATURE @"Signature"

#define INVALID_MAXIMUM_SUBJECTS 10
/**
 invalid/valid values for the governor of activites: markChar
 */
#define INVALID_LICENSE_BYTE1 0xFA
#define VALID_LICENSE_BYTE1 0xAF

/**
 invaldi/valid values for the governor of subjects: modder
 */
#define INVALID_LICENSE_BYTE2 0x31
#define VALID_LICENSE_BYTE2 0x0E

#define INVALID_MAXIMUM_ACTIVITIES 20

#define TSK_KEY_PULSE_STATE @"state"
#define TSK_KEY_PULSE_DATA @"data"
