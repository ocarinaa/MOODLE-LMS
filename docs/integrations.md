# 🔗 Moodle LMS Integrations Guide

Detailed configuration and usage guide for integrating the Moodle LMS system with external systems.

## 📋 Table of Contents

1. [BigBlueButton Integration](#bigbluebutton-integration)
2. [Examus Proctoring System](#examus-proctoring-system)
3. [Safe Exam Browser](#safe-exam-browser)
4. [Odoo ERP Integration](#odoo-erp-integration)
5. [LDAP/Active Directory](#ldap-active-directory)
6. [Single Sign-On (SSO)](#single-sign-on-sso)
7. [API Integrations](#api-integrations)
8. [Webhook Configurations](#webhook-configurations)

---

## 📹 BigBlueButton Integration

### Installation and Configuration

#### 1. BigBlueButton Server Installation

```bash
# BigBlueButton installation on Ubuntu 20.04
wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -w -a -v focal-260 -s your-bbb-domain.com -e info@example.com

# Open firewall ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 1935/tcp
ufw allow 7443/tcp
ufw allow 16384:32768/udp
```

#### 2. Moodle BigBlueButton Plugin Installation

```bash
# Enter Moodle container
docker exec -it moodle-lms-moodle bash

# Go to plugin directory
cd /opt/bitnami/moodle/mod

# Download BigBlueButton plugin
wget https://github.com/blindsidenetworks/moodle-mod_bigbluebuttonbn/archive/refs/heads/master.zip
unzip master.zip
mv moodle-mod_bigbluebuttonbn-master bigbluebuttonbn

# Set ownership
chown -R bitnami:bitnami bigbluebuttonbn

exit
```

#### 3. Plugin Configuration

```php
// Add to config/moodle/config.php
$CFG->bigbluebuttonbn_server_url = getenv('BBB_SERVER_URL') ?: 'https://your-bbb-server.com/bigbluebutton/api/';
$CFG->bigbluebuttonbn_shared_secret = getenv('BBB_SHARED_SECRET') ?: 'your_shared_secret';

// BigBlueButton custom settings
$CFG->bigbluebuttonbn_voicebridge_editable = true;
$CFG->bigbluebuttonbn_importrecordings_enabled = true;
$CFG->bigbluebuttonbn_meetingevents_enabled = true;
$CFG->bigbluebuttonbn_recordingready_enabled = true;
$CFG->bigbluebuttonbn_recordingstatus_enabled = true;

// Security settings
$CFG->bigbluebuttonbn_moderator_default = 'owner';
$CFG->bigbluebuttonbn_voicebridge_editable = false;
```

#### 4. Environment Variables

```bash
# Add BigBlueButton settings to .env file
cat >> .env << 'EOF'

# BigBlueButton Configuration
BBB_SERVER_URL=https://your-bbb-server.com/bigbluebutton/api/
BBB_SHARED_SECRET=your_shared_secret_here
BBB_WEBHOOK_URL=https://your-domain.com/mod/bigbluebuttonbn/bbb_webhook.php

# BigBlueButton Features
BBB_RECORDING_ENABLED=true
BBB_RECORDING_AUTO_START=false
BBB_WEBCAMS_ONLY_FOR_MODERATOR=false
BBB_MUTE_ON_START=true
EOF
```

#### 5. Webhook Configuration

```php
<?php
// webhooks/bigbluebutton_webhook.php

require_once('../../config.php');
require_login();

// Webhook verification
function verify_bbb_webhook($payload, $signature, $shared_secret) {
    $expected_signature = hash_hmac('sha256', $payload, $shared_secret);
    return hash_equals($signature, $expected_signature);
}

// Webhook handler
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $payload = file_get_contents('php://input');
    $signature = $_SERVER['HTTP_X_BBB_SIGNATURE'] ?? '';
    
    if (verify_bbb_webhook($payload, $signature, $CFG->bigbluebuttonbn_shared_secret)) {
        $data = json_decode($payload, true);
        
        switch ($data['event']) {
            case 'meeting-ended':
                // Actions when meeting ends
                handle_meeting_ended($data);
                break;
                
            case 'recording-ready':
                // Actions when recording is ready
                handle_recording_ready($data);
                break;
                
            case 'user-joined':
                // Actions when user joins
                handle_user_joined($data);
                break;
        }
        
        http_response_code(200);
        echo 'OK';
    } else {
        http_response_code(401);
        echo 'Unauthorized';
    }
}

function handle_meeting_ended($data) {
    global $DB;
    
    $meeting_id = $data['meeting_id'];
    $duration = $data['duration'];
    
    // Update meeting information in database
    $record = $DB->get_record('bigbluebuttonbn', ['meetingid' => $meeting_id]);
    if ($record) {
        $record->timemodified = time();
        $record->duration = $duration;
        $DB->update_record('bigbluebuttonbn', $record);
        
        // Send meeting summary email
        send_meeting_summary_email($record);
    }
}

function handle_recording_ready($data) {
    global $DB;
    
    $meeting_id = $data['meeting_id'];
    $recording_url = $data['recording_url'];
    
    // Update recording URL in database
    $record = $DB->get_record('bigbluebuttonbn', ['meetingid' => $meeting_id]);
    if ($record) {
        $record->recordings = json_encode(['url' => $recording_url, 'ready' => true]);
        $DB->update_record('bigbluebuttonbn', $record);
        
        // Notify participants recording is ready
        notify_recording_ready($record, $recording_url);
    }
}
?>
```

#### 6. Custom BBB Settings

```javascript
// mod/bigbluebuttonbn/js/custom_bbb.js

// Custom settings before starting meeting
window.addEventListener('beforeunload', function(e) {
    // Save meeting data
    saveMeetingData();
});

function saveMeetingData() {
    const meetingData = {
        duration: getMeetingDuration(),
        participants: getParticipantCount(),
        timestamp: new Date().toISOString()
    };
    
    fetch('/mod/bigbluebuttonbn/ajax/save_meeting_data.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(meetingData)
    });
}

// Custom CSS for BigBlueButton iframe
function customizeBBBInterface() {
    const iframe = document.querySelector('#bigbluebutton-iframe');
    if (iframe) {
        iframe.onload = function() {
            try {
                const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
                const style = iframeDoc.createElement('style');
                style.textContent = `
                    .branding { display: none !important; }
                    .navbar-brand img { content: url('/theme/moodlelms/pix/logo.png') !important; }
                    .navbar { background-color: #FF6600 !important; }
                `;
                iframeDoc.head.appendChild(style);
            } catch(e) {
                console.log('BigBlueButton iframe customization failed:', e);
            }
        };
    }
}

// Run when page loads
document.addEventListener('DOMContentLoaded', customizeBBBInterface);
```

---

## 🔍 Examus Proctoring System

### Installation and Configuration

#### 1. Examus Plugin Installation

```bash
# Enter Moodle container
docker exec -it moodle-lms-moodle bash

# Examus availability condition plugin
cd /opt/bitnami/moodle/availability/condition
git clone https://github.com/examus/moodle-availability_examus.git examus

# Examus OAuth plugin
cd /opt/bitnami/moodle/local
git clone https://github.com/examus/moodle-local_oauth.git oauth

# Set ownership
chown -R bitnami:bitnami /opt/bitnami/moodle/availability/condition/examus
chown -R bitnami:bitnami /opt/bitnami/moodle/local/oauth

exit
```

#### 2. Web Service Configuration

```bash
# Enable web services
docker exec moodle-lms-moodle php /opt/bitnami/moodle/admin/cli/cfg.php --name=enablewebservices --set=1

# Enable REST protocol
docker exec moodle-lms-moodle php /opt/bitnami/moodle/admin/cli/cfg.php --name=webserviceprotocols --set=rest

# Create custom web service for Examus
cat > /tmp/create_examus_service.php << 'EOF'
<?php
require_once('/opt/bitnami/moodle/config.php');
require_once($CFG->libdir.'/adminlib.php');

// Create web service
$webservice = new stdClass();
$webservice->name = 'Examus';
$webservice->enabled = 1;
$webservice->restrictedusers = 1;
$webservice->component = 'availability_examus';
$webservice->timecreated = time();
$webservice->timemodified = time();
$webservice->downloadfiles = 0;
$webservice->uploadfiles = 0;

$serviceid = $DB->insert_record('external_services', $webservice);

// Add required functions
$functions = [
    'core_user_get_users',
    'core_course_get_courses',
    'core_enrol_get_enrolled_users',
    'gradereport_user_get_grade_items',
    'mod_quiz_get_quizzes_by_courses',
    'mod_quiz_get_quiz_by_courseid',
    'mod_quiz_view_quiz'
];

foreach ($functions as $functionname) {
    $function = $DB->get_record('external_functions', ['name' => $functionname]);
    if ($function) {
        $servicefunction = new stdClass();
        $servicefunction->externalserviceid = $serviceid;
        $servicefunction->functionname = $functionname;
        $DB->insert_record('external_services_functions', $servicefunction);
    }
}

echo "Examus web service created with ID: $serviceid\n";
?>
EOF

# Run the script
docker exec moodle-lms-moodle php /tmp/create_examus_service.php
```

#### 3. Token Creation

```bash
# Create Examus user
docker exec moodle-lms-moodle php /opt/bitnami/moodle/admin/cli/create_user.php \
    --username=examus \
    --password=ExamusSecure2025! \
    --email=examus@example.com \
    --firstname=Examus \
    --lastname=Service

# Create token
docker exec moodle-lms-moodle php -r "
require_once('/opt/bitnami/moodle/config.php');

\$user = \$DB->get_record('user', ['username' => 'examus']);
\$service = \$DB->get_record('external_services', ['name' => 'Examus']);

\$token = new stdClass();
\$token->token = md5(uniqid(rand(), true));
\$token->userid = \$user->id;
\$token->tokentype = 0;
\$token->contextid = 1;
\$token->creatorid = 2;
\$token->externalserviceid = \$service->id;
\$token->timecreated = time();
\$token->timemodified = time();
\$token->iprestriction = '';
\$token->validuntil = null;

\$tokenid = \$DB->insert_record('external_tokens', \$token);
echo \"Token created: \" . \$token->token . \"\n\";
"
```

#### 4. Examus Configuration

```php
// Add to config/moodle/config.php
$CFG->examus_app_url = 'https://your-domain.com/webservice/rest/server.php';
$CFG->examus_token = 'generated_token_from_above';
$CFG->examus_client_id = 'moodle_client_id';
$CFG->examus_client_secret = 'moodle_client_secret';

// Examus security settings
$CFG->examus_identification_mode = 'strict'; // strict, normal, disabled
$CFG->examus_enable_screenshot = true;
$CFG->examus_enable_webcam = true;
$CFG->examus_enable_desktop_recording = true;
$CFG->examus_enable_chat_detection = true;
```

#### 5. Examus Exam Configuration

```php
<?php
// availability/condition/examus/classes/condition.php

class condition extends \core_availability\condition {
    
    protected $examusconfig;
    
    public function __construct($structure) {
        $this->examusconfig = json_decode($structure->examus_config ?? '{}', true);
    }
    
    public function is_available($not, info $info, $grabthelot, $userid) {
        global $USER, $CFG;
        
        // Check if Examus application is being monitored
        if (!$this->is_examus_app_active($userid)) {
            return false;
        }
        
        // Identity verification check
        if (!$this->verify_user_identity($userid)) {
            return false;
        }
        
        return true;
    }
    
    protected function is_examus_app_active($userid) {
        // Check if Examus application is active
        $api_url = $CFG->examus_app_url;
        $token = $CFG->examus_token;
        
        $params = [
            'wstoken' => $token,
            'wsfunction' => 'availability_examus_check_app_status',
            'moodlewsrestformat' => 'json',
            'userid' => $userid
        ];
        
        $response = $this->make_api_request($api_url, $params);
        return $response['app_active'] ?? false;
    }
    
    protected function verify_user_identity($userid) {
        // Identity verification process
        return $this->examusconfig['require_identity_verification'] ?? true;
    }
    
    protected function make_api_request($url, $params) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($params));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        
        $response = curl_exec($ch);
        curl_close($ch);
        
        return json_decode($response, true) ?? [];
    }
}
?>
```

---

## 🛡️ Safe Exam Browser

### Installation and Configuration

#### 1. SEB Plugin Installation

```bash
# Download Safe Exam Browser plugin
docker exec moodle-lms-moodle bash -c "
cd /opt/bitnami/moodle/mod
wget https://github.com/SafeExamBrowser/seb-moodle/archive/refs/heads/master.zip -O seb.zip
unzip seb.zip
mv seb-moodle-master seb
chown -R bitnami:bitnami seb
rm seb.zip
"
```

#### 2. SEB Configuration File

```json
{
  "originatorVersion": "SEB_3.4",
  "sebConfigPurpose": 2,
  "allowBrowsingBackForward": false,
  "allowDisplayMirroring": false,
  "allowDownloads": false,
  "allowFlashFullscreen": false,
  "allowPDFPlugIn": true,
  "allowQuit": false,
  "allowReloading": true,
  "allowSpellCheck": false,
  "allowUserAppFolderInstall": false,
  "allowVideoCapture": false,
  "allowVirtualMachine": false,
  "browserWindowAllowReload": true,
  "browserWindowShowURL": false,
  "enableAltEsc": false,
  "enableAltF4": false,
  "enableAltTab": false,
  "enableCtrlAltDel": false,
  "enableEsc": false,
  "enableF1": false,
  "enableF2": false,
  "enableF3": false,
  "enableF4": false,
  "enableF5": true,
  "enableF6": false,
  "enableF7": false,
  "enableF8": false,
  "enableF9": false,
  "enableF10": false,
  "enableF11": false,
  "enableF12": false,
  "enablePrintScreen": false,
  "enableRightMouse": false,
  "enableZoomPage": false,
  "enableZoomText": false,
  "exitKey1": 2,
  "exitKey2": 10,
  "exitKey3": 5,
  "hashedQuitPassword": "c9e8c26b6e8d3f4f5a5b3c8e1a2f4d6e8c9d1f2a",
  "killExplorerShell": true,
  "mainBrowserWindowHeight": "100%",
  "mainBrowserWindowPositioning": 1,
  "mainBrowserWindowWidth": "100%",
  "newBrowserWindowByLinkHeight": "100%",
  "newBrowserWindowByLinkPositioning": 2,
  "newBrowserWindowByLinkWidth": "100%",
  "restartExamPasswordHash": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
  "sebServiceIgnore": false,
  "showInputLanguage": true,
  "showReloadButton": true,
  "showTime": false,
  "startURL": "https://your-domain.com/course/view.php?id=COURSEID",
  "touchOptimized": false,
  "urlFilterEnable": true,
  "urlFilterRules": [
    {
      "action": 1,
      "active": true,
      "expression": "https://your-domain.com/*",
      "regex": false
    },
    {
      "action": 0,
      "active": true,
      "expression": "*",
      "regex": false
    }
  ]
}
```

#### 3. Moodle SEB Settings

```php
// Add SEB settings to config/moodle/config.php
$CFG->seb_enabled = true;
$CFG->seb_requiresafeexambrowser = true;
$CFG->seb_showsebtaskbar = false;
$CFG->seb_showwificontrol = false;
$CFG->seb_enableaudiocontrol = false;
$CFG->seb_muteoninitialisation = true;
$CFG->seb_allowuserquitseb = false;
$CFG->seb_quitlink = 'https://your-domain.com/course/';
$CFG->seb_linkquitseb = 'https://your-domain.com/';
```

#### 4. Quiz SEB Integration

```php
<?php
// mod/quiz/classes/seb_quiz_settings.php

class seb_quiz_settings {
    
    public static function get_seb_config_for_quiz($quizid) {
        global $DB;
        
        $quiz = $DB->get_record('quiz', ['id' => $quizid]);
        if (!$quiz) {
            return null;
        }
        
        // Create SEB configuration
        $seb_config = [
            'sebConfigPurpose' => 2,
            'startURL' => self::get_quiz_url($quiz),
            'quitURL' => self::get_quit_url($quiz),
            'allowBrowsingBackForward' => false,
            'allowReloading' => true,
            'allowSpellCheck' => false,
            'enableRightMouse' => false,
            'urlFilterEnable' => true,
            'urlFilterRules' => self::get_url_filter_rules()
        ];
        
        return json_encode($seb_config);
    }
    
    private static function get_quiz_url($quiz) {
        global $CFG;
        return $CFG->wwwroot . '/mod/quiz/view.php?id=' . $quiz->coursemodule;
    }
    
    private static function get_quit_url($quiz) {
        global $CFG;
        return $CFG->wwwroot . '/course/view.php?id=' . $quiz->course;
    }
    
    private static function get_url_filter_rules() {
        global $CFG;
        
        return [
            [
                'action' => 1,
                'active' => true,
                'expression' => $CFG->wwwroot . '/*',
                'regex' => false
            ],
            [
                'action' => 0,
                'active' => true,
                'expression' => '*',
                'regex' => false
            ]
        ];
    }
    
    public static function validate_seb_access($quizid) {
        $headers = getallheaders();
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        // SEB user agent check
        if (strpos($user_agent, 'SEB/') === false) {
            return false;
        }
        
        // SEB config key check
        $config_key = $headers['X-SafeExamBrowser-ConfigKeyHash'] ?? '';
        $expected_key = self::calculate_config_key($quizid);
        
        return hash_equals($config_key, $expected_key);
    }
    
    private static function calculate_config_key($quizid) {
        $config = self::get_seb_config_for_quiz($quizid);
        return hash('sha256', $config . 'your-secret-salt');
    }
}
?>
```

---

## 🏢 Odoo ERP Integration

### Moodle Side Configuration

#### 1. Web Service Setup

```bash
# Create web service for Odoo
cat > /tmp/create_odoo_service.php << 'EOF'
<?php
require_once('/opt/bitnami/moodle/config.php');

// Create web service
$webservice = new stdClass();
$webservice->name = 'Odoo Integration';
$webservice->enabled = 1;
$webservice->restrictedusers = 1;
$webservice->downloadfiles = 1;
$webservice->uploadfiles = 1;
$webservice->timecreated = time();
$webservice->timemodified = time();

$serviceid = $DB->insert_record('external_services', $webservice);

// Add functions
$functions = [
    'core_user_get_users',
    'core_user_create_users',
    'core_user_update_users',
    'core_course_get_courses',
    'core_course_create_courses',
    'core_enrol_get_enrolled_users',
    'enrol_manual_enrol_users',
    'gradereport_user_get_grade_items',
    'core_grades_get_grades'
];

foreach ($functions as $functionname) {
    $function = $DB->get_record('external_functions', ['name' => $functionname]);
    if ($function) {
        $servicefunction = new stdClass();
        $servicefunction->externalserviceid = $serviceid;
        $servicefunction->functionname = $functionname;
        $DB->insert_record('external_services_functions', $servicefunction);
    }
}

// Create token
$user = $DB->get_record('user', ['username' => 'admin']);
$token = new stdClass();
$token->token = 'odoo_' . md5(uniqid(rand(), true));
$token->userid = $user->id;
$token->tokentype = 0;
$token->contextid = 1;
$token->creatorid = $user->id;
$token->externalserviceid = $serviceid;
$token->timecreated = time();
$token->timemodified = time();

$tokenid = $DB->insert_record('external_tokens', $token);
echo "Odoo web service token: " . $token->token . "\n";
?>
EOF

docker exec moodle-lms-moodle php /tmp/create_odoo_service.php
```

#### 2. Custom API Endpoints

```php
<?php
// local/odoo_integration/externallib.php

class local_odoo_integration_external extends external_api {
    
    /**
     * User synchronization
     */
    public static function sync_users($users) {
        global $DB, $CFG;
        
        $results = [];
        foreach ($users as $userdata) {
            try {
                $user = $DB->get_record('user', ['email' => $userdata['email']]);
                
                if ($user) {
                    // Update existing user
                    $user->firstname = $userdata['firstname'];
                    $user->lastname = $userdata['lastname'];
                    $user->timemodified = time();
                    $DB->update_record('user', $user);
                    $results[] = ['email' => $userdata['email'], 'status' => 'updated'];
                } else {
                    // Create new user
                    $user = new stdClass();
                    $user->username = $userdata['username'];
                    $user->password = hash_internal_user_password($userdata['password']);
                    $user->firstname = $userdata['firstname'];
                    $user->lastname = $userdata['lastname'];
                    $user->email = $userdata['email'];
                    $user->confirmed = 1;
                    $user->mnethostid = $CFG->mnet_localhost_id;
                    $user->timecreated = time();
                    $user->timemodified = time();
                    
                    $userid = $DB->insert_record('user', $user);
                    $results[] = ['email' => $userdata['email'], 'status' => 'created', 'userid' => $userid];
                }
            } catch (Exception $e) {
                $results[] = ['email' => $userdata['email'], 'status' => 'error', 'message' => $e->getMessage()];
            }
        }
        
        return $results;
    }
    
    /**
     * Course enrollment synchronization
     */
    public static function sync_enrollments($enrollments) {
        global $DB;
        
        $results = [];
        foreach ($enrollments as $enrollment) {
            try {
                $user = $DB->get_record('user', ['email' => $enrollment['user_email']]);
                $course = $DB->get_record('course', ['shortname' => $enrollment['course_shortname']]);
                
                if (!$user || !$course) {
                    $results[] = [
                        'user_email' => $enrollment['user_email'],
                        'course_shortname' => $enrollment['course_shortname'],
                        'status' => 'error',
                        'message' => 'User or course not found'
                    ];
                    continue;
                }
                
                // Enrollment process
                $enrol_manual = $DB->get_record('enrol', [
                    'courseid' => $course->id,
                    'enrol' => 'manual'
                ]);
                
                if ($enrol_manual) {
                    $manual = enrol_get_plugin('manual');
                    $manual->enrol_user($enrol_manual, $user->id, 5); // Student role
                    
                    $results[] = [
                        'user_email' => $enrollment['user_email'],
                        'course_shortname' => $enrollment['course_shortname'],
                        'status' => 'enrolled'
                    ];
                }
                
            } catch (Exception $e) {
                $results[] = [
                    'user_email' => $enrollment['user_email'],
                    'course_shortname' => $enrollment['course_shortname'],
                    'status' => 'error',
                    'message' => $e->getMessage()
                ];
            }
        }
        
        return $results;
    }
    
    /**
     * Export grades to Odoo
     */
    public static function export_grades($course_id, $user_ids = []) {
        global $DB, $CFG;
        
        require_once($CFG->libdir . '/gradelib.php');
        
        $grades_data = [];
        $course = $DB->get_record('course', ['id' => $course_id]);
        
        if (!$course) {
            return ['error' => 'Course not found'];
        }
        
        // User list
        if (empty($user_ids)) {
            $enrolled_users = get_enrolled_users(context_course::instance($course_id));
            $user_ids = array_keys($enrolled_users);
        }
        
        foreach ($user_ids as $user_id) {
            $user = $DB->get_record('user', ['id' => $user_id]);
            if (!$user) continue;
            
            $grade_items = grade_get_course_grades($course_id, $user_id);
            
            $user_grades = [
                'user_email' => $user->email,
                'course_shortname' => $course->shortname,
                'grades' => []
            ];
            
            if ($grade_items) {
                foreach ($grade_items as $item) {
                    $user_grades['grades'][] = [
                        'item_name' => $item->str_long_grade,
                        'grade' => $item->grade,
                        'max_grade' => $item->grademax,
                        'date' => date('Y-m-d H:i:s', $item->dategraded)
                    ];
                }
            }
            
            $grades_data[] = $user_grades;
        }
        
        return $grades_data;
    }
}
?>
```

### Odoo Side Configuration

#### 1. Moodle Connector Module

```python
# addons/moodle_connector/models/moodle_config.py

from odoo import models, fields, api
import requests
import json
import logging

_logger = logging.getLogger(__name__)

class MoodleConnector(models.Model):
    _name = 'moodle.connector'
    _description = 'Moodle Integration Configuration'
    
    name = fields.Char('Configuration Name', required=True)
    url = fields.Char('Moodle URL', required=True)
    token = fields.Char('API Token', required=True)
    is_active = fields.Boolean('Active', default=True)
    last_sync = fields.Datetime('Last Synchronization')
    sync_users = fields.Boolean('Sync Users', default=True)
    sync_courses = fields.Boolean('Sync Courses', default=True)
    sync_grades = fields.Boolean('Sync Grades', default=True)
    
    def test_connection(self):
        """Test Moodle connection"""
        try:
            response = self._make_api_request('core_webservice_get_site_info')
            if response:
                return {
                    'type': 'ir.actions.client',
                    'tag': 'display_notification',
                    'params': {
                        'title': 'Connection Successful',
                        'message': f"Connected to {response.get('sitename')}",
                        'type': 'success',
                    }
                }
        except Exception as e:
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': 'Connection Failed',
                    'message': str(e),
                    'type': 'danger',
                }
            }
    
    def _make_api_request(self, function, params=None):
        """Make API request to Moodle"""
        if params is None:
            params = {}
            
        params.update({
            'wstoken': self.token,
            'wsfunction': function,
            'moodlewsrestformat': 'json'
        })
        
        try:
            response = requests.get(f"{self.url}/webservice/rest/server.php", params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            _logger.error(f"Moodle API request failed: {e}")
            raise
    
    def sync_users_to_moodle(self):
        """Sync Odoo users to Moodle"""
        if not self.sync_users:
            return
            
        users = self.env['res.users'].search([('active', '=', True)])
        moodle_users = []
        
        for user in users:
            if user.email and user.name:
                moodle_users.append({
                    'username': user.login,
                    'password': 'temporary_password_' + str(user.id),
                    'firstname': user.name.split(' ')[0],
                    'lastname': ' '.join(user.name.split(' ')[1:]) if len(user.name.split(' ')) > 1 else '',
                    'email': user.email
                })
        
        if moodle_users:
            try:
                response = self._make_api_request('local_odoo_integration_sync_users', {
                    'users': json.dumps(moodle_users)
                })
                self.last_sync = fields.Datetime.now()
                _logger.info(f"Synced {len(moodle_users)} users to Moodle")
                return response
            except Exception as e:
                _logger.error(f"User sync failed: {e}")
                raise
    
    def get_moodle_grades(self, course_id):
        """Get grades from Moodle course"""
        try:
            response = self._make_api_request('local_odoo_integration_export_grades', {
                'course_id': course_id
            })
            return response
        except Exception as e:
            _logger.error(f"Grade export failed: {e}")
            raise
    
    @api.model
    def cron_sync_data(self):
        """Scheduled synchronization"""
        connectors = self.search([('is_active', '=', True)])
        for connector in connectors:
            try:
                if connector.sync_users:
                    connector.sync_users_to_moodle()
                _logger.info(f"Sync completed for {connector.name}")
            except Exception as e:
                _logger.error(f"Sync failed for {connector.name}: {e}")
```

#### 2. Webhook Handler

```python
# addons/moodle_connector/controllers/webhook.py

from odoo import http
from odoo.http import request
import json
import hmac
import hashlib

class MoodleWebhook(http.Controller):
    
    @http.route('/moodle/webhook', type='json', auth='none', methods=['POST'], csrf=False)
    def handle_webhook(self, **kwargs):
        """Handle webhooks from Moodle"""
        
        # Webhook verification
        signature = request.httprequest.headers.get('X-Moodle-Signature', '')
        body = request.httprequest.get_data()
        
        if not self._verify_signature(body, signature):
            return {'error': 'Invalid signature'}
        
        try:
            data = json.loads(body.decode('utf-8'))
            event_type = data.get('event_type')
            
            if event_type == 'user_enrolled':
                return self._handle_enrollment(data)
            elif event_type == 'grade_updated':
                return self._handle_grade_update(data)
            elif event_type == 'course_completed':
                return self._handle_course_completion(data)
            
            return {'status': 'success'}
            
        except Exception as e:
            return {'error': str(e)}
    
    def _verify_signature(self, body, signature):
        """Verify webhook signature"""
        secret = request.env['ir.config_parameter'].sudo().get_param('moodle.webhook_secret')
        expected = hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()
        return hmac.compare_digest(signature, expected)
    
    def _handle_enrollment(self, data):
        """Handle user enrollment event"""
        # Process enrollment operations in Odoo
        return {'status': 'enrollment_processed'}
    
    def _handle_grade_update(self, data):
        """Handle grade update event"""
        # Process grade updates in Odoo
        return {'status': 'grade_processed'}
    
    def _handle_course_completion(self, data):
        """Handle course completion event"""
        # Record course completion status in Odoo
        return {'status': 'completion_processed'}
```

---

## 🔐 LDAP/Active Directory

### LDAP Configuration

```php
// Add LDAP settings to config/moodle/config.php

// LDAP authentication plugin
$CFG->auth_ldap_host_url = 'ldaps://your-dc.domain.com:636';
$CFG->auth_ldap_version = 3;
$CFG->auth_ldap_ldap_encoding = 'utf-8';
$CFG->auth_ldap_user_type = 'ad';

// Bind settings
$CFG->auth_ldap_bind_dn = 'CN=moodle-service,OU=Service Accounts,DC=domain,DC=com';
$CFG->auth_ldap_bind_pw = 'service_account_password';

// User contexts
$CFG->auth_ldap_contexts = 'OU=Students,DC=domain,DC=com;OU=Teachers,DC=domain,DC=com';
$CFG->auth_ldap_search_sub = 1;

// User attribute mapping
$CFG->auth_ldap_user_attribute = 'sAMAccountName';
$CFG->auth_ldap_memberattribute = 'memberOf';
$CFG->auth_ldap_memberattribute_isdn = 1;

// Field mapping
$CFG->auth_ldap_field_map_firstname = 'givenName';
$CFG->auth_ldap_field_map_lastname = 'sn';
$CFG->auth_ldap_field_map_email = 'mail';
$CFG->auth_ldap_field_map_phone1 = 'telephoneNumber';
$CFG->auth_ldap_field_map_department = 'department';

// SSL settings
$CFG->auth_ldap_start_tls = 0;
$CFG->auth_ldap_ldap_encoding = 'utf-8';
```

---

## 🎫 Single Sign-On (SSO)

### SAML2 SSO Configuration

```bash
# Install SAML2 auth plugin
docker exec moodle-lms-moodle bash -c "
cd /opt/bitnami/moodle/auth
git clone https://github.com/catalyst/moodle-auth_saml2.git saml2
chown -R bitnami:bitnami saml2
"
```

```php
// SAML2 settings
$CFG->auth_saml2_idpname = 'Corporate SSO';
$CFG->auth_saml2_entityid = 'https://your-domain.com/auth/saml2/sp/metadata.php';
$CFG->auth_saml2_sso_url = 'https://your-sso-provider.com/saml2/sso';
$CFG->auth_saml2_slo_url = 'https://your-sso-provider.com/saml2/slo';
$CFG->auth_saml2_x509cert = 'your_idp_certificate_content';

// Field mapping
$CFG->auth_saml2_field_map_firstname = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname';
$CFG->auth_saml2_field_map_lastname = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname';
$CFG->auth_saml2_field_map_email = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
```

---

## 🌐 API Integrations

### REST API Client

```javascript
// js/moodle_api_client.js

class MoodleAPIClient {
    constructor(baseUrl, token) {
        this.baseUrl = baseUrl;
        this.token = token;
    }
    
    async makeRequest(wsfunction, params = {}) {
        const requestParams = {
            wstoken: this.token,
            wsfunction: wsfunction,
            moodlewsrestformat: 'json',
            ...params
        };
        
        const url = new URL(`${this.baseUrl}/webservice/rest/server.php`);
        Object.keys(requestParams).forEach(key => 
            url.searchParams.append(key, requestParams[key])
        );
        
        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return await response.json();
        } catch (error) {
            console.error('API request failed:', error);
            throw error;
        }
    }
    
    // User operations
    async getUsers(criteria = []) {
        return await this.makeRequest('core_user_get_users', { 
            criteria: JSON.stringify(criteria) 
        });
    }
    
    async createUser(user) {
        return await this.makeRequest('core_user_create_users', {
            users: JSON.stringify([user])
        });
    }
    
    // Course operations
    async getCourses() {
        return await this.makeRequest('core_course_get_courses');
    }
    
    async getCourseContents(courseid) {
        return await this.makeRequest('core_course_get_contents', { courseid });
    }
    
    // Grade operations
    async getGrades(courseid, userid) {
        return await this.makeRequest('gradereport_user_get_grade_items', {
            courseid, userid
        });
    }
}

// Usage example
const moodleAPI = new MoodleAPIClient(
    'https://your-domain.com', 
    'your_api_token'
);

// Async/await usage
async function syncUserData() {
    try {
        const users = await moodleAPI.getUsers([
            { key: 'email', value: 'student@example.com' }
        ]);
        console.log('Users:', users);
    } catch (error) {
        console.error('Sync failed:', error);
    }
}
```

---

## 🔗 Webhook Configurations

### Generic Webhook Handler

```php
<?php
// webhooks/generic_webhook.php

require_once('../../config.php');

class WebhookHandler {
    
    private $secret;
    
    public function __construct($secret) {
        $this->secret = $secret;
    }
    
    public function handle() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo 'Method not allowed';
            return;
        }
        
        $payload = file_get_contents('php://input');
        $signature = $_SERVER['HTTP_X_HUB_SIGNATURE'] ?? '';
        
        if (!$this->verify_signature($payload, $signature)) {
            http_response_code(401);
            echo 'Unauthorized';
            return;
        }
        
        $data = json_decode($payload, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            http_response_code(400);
            echo 'Invalid JSON';
            return;
        }
        
        $this->process_webhook($data);
        
        http_response_code(200);
        echo 'OK';
    }
    
    private function verify_signature($payload, $signature) {
        if (empty($signature)) {
            return false;
        }
        
        $expected = 'sha1=' . hash_hmac('sha1', $payload, $this->secret);
        return hash_equals($signature, $expected);
    }
    
    private function process_webhook($data) {
        global $DB;
        
        $event_type = $data['event'] ?? 'unknown';
        
        switch ($event_type) {
            case 'user_created':
                $this->handle_user_created($data);
                break;
                
            case 'course_enrolled':
                $this->handle_course_enrolled($data);
                break;
                
            case 'grade_updated':
                $this->handle_grade_updated($data);
                break;
                
            default:
                error_log("Unknown webhook event: $event_type");
        }
        
        // Log webhook
        $log = new stdClass();
        $log->event_type = $event_type;
        $log->payload = json_encode($data);
        $log->processed_at = time();
        $DB->insert_record('webhook_logs', $log);
    }
    
    private function handle_user_created($data) {
        // Handle user creation operations
        error_log("User created: " . $data['user']['email']);
    }
    
    private function handle_course_enrolled($data) {
        // Handle course enrollment operations
        error_log("User enrolled: " . $data['user_id'] . " in course " . $data['course_id']);
    }
    
    private function handle_grade_updated($data) {
        // Handle grade update operations
        error_log("Grade updated for user: " . $data['user_id']);
    }
}

// Start webhook handler
$webhook_secret = $CFG->webhook_secret ?? 'default_secret';
$handler = new WebhookHandler($webhook_secret);
$handler->handle();
?>
```

---

## 📞 Support

For support with integrations:

- 🐛 **GitHub Issues**: [Issues page](https://github.com/umur957/moodle-lms/issues)
- 📚 **Documentation**: [docs/](../README.md)

---

*This integrations guide is continuously updated. You can share your new integration suggestions through GitHub Issues.*