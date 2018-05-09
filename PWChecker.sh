#!/bin/bash
###################### Get current user ########################

CurrentUser=`ls -l /dev/console | cut -d " " -f4`

#set Password Policy
PWPolicy=59
#set Password Notification
PWNotify=14

#get Last Password change from DSCL
MSLastPWD=`dscl "/Active Directory/IGS/All Domains" -read /Users/$CurrentUser | grep -i SMBPasswordLastSet | cut -d ' ' -f 2 | sed q`
#get today's date in Unix time
todayUnix=`date "+%s"`
#Convert Last Password Change date into Unix Time
lastPWDUnix=$((MSLastPWD / 10000000 - 11644473600))
#Calculate Difference between Today's Date and Last Changed Date
diffUnix=$((todayUnix - lastPWDUnix))
#Calculate number of days since last Password change
diffDays=$((diffUnix / 86400 ))
#calculate Number of days until password Expiry
expireDays=$((PWPolicy - diffDays ))
#expireDays=9
#echo $expireDays

if [[ $expireDays -le $PWNotify ]]; then
  #Prompt User that their password is due to expire soon
  RESULT=`"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType utility -title Ivanhoe Grammar School - IT Services -heading "Your Password is due to expire in $expireDays Days" -alignHeading center -description "Your password is due to expire in $expireDays Days. Please Change your password now to avoid account access problems. If you aren't sure how to change your password, please come to IT Services for Assistance." -alignDescription center -icon "/Users/Shared/.profiles/Crest 4x6.png" -button1 "Ignore" -button2 "Change Now" -defaultButton 0 -cancelButton 0 -lockHUD`
fi

if [[ $RESULT = 0 ]]; then
  #On Ignore, provide user an opportunity to change their mind
  RESULT2=`"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType utility -title Ivanhoe Grammar School - IT Services -heading "Your Password is due to expire in $expireDays Days" -alignHeading center -description "You have chosen to Ignore this warning. Are you sure you want to do this?" -alignDescription center -icon "/Users/Shared/.profiles/Crest 4x6.png" -button1 "Ignore" -button2 "Change Now" -defaultButton 0 -cancelButton 0 -lockHUD`
elif [[ $RESULT = 2 ]]; then
  #open System Preferences -> Accounts preference pane
  sudo -u $CurrentUser open /System/Library/PreferencePanes/Accounts.prefPane
fi

if [[ $RESULT2 = 2 ]]; then
  #open System Preferences -> Accounts preference pane
  sudo -u $CurrentUser open /System/Library/PreferencePanes/Accounts.prefPane
fi
