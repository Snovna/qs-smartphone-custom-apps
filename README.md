# Custom Apps for QS-Smartphone

## Emergency App (Dispatch App)
Easy to use app to handle Emergency Situations

Features
- (Civilian) Send dispatch to Law Enforcement
- (Law Enforcement) Issue Alerts with 3 different categories
- (Law Enforcement) Page Off-Duty colleagues through the app
- (Both) Settings for receiving Warning/Pager Messages

### Config
Config for the Script is currently inside the client file and needs to be refactored

```
-- Configure Dispatch Options
Config.EmergencyDispatch = {
    [1] = { job = 'police', display = 'LSPD' },
    [2] = { job = 'ambulance', display = 'LSMD' },
    [3] = { job = 'doj', display = 'DoJ' },
    [4] = { job = 'regierung', display = 'Regierung' },
}
-- Configure Access to Menus
Config.EmergencyAccess = {
    ['police'] = {
        warning = true,
        pager = true,
        pagerOptions = {
            [1] = {display = 'Off-Duty LSPD', jobs = {'offpolice','police'}},
            [2] = {display = 'Off-Duty LSMD', jobs = {'offambulance','ambulance'}},
        }
    },
    ['ambulance'] = {
        warning = true,
        pager = true,
        pagerOptions = {
            [1] = {display = 'Off-Duty LSMD', jobs = {'offambulance','ambulance'}},
            [2] = {display = 'Off-Duty LSPD', jobs = {'offpolice','police'}},
        }
    },
    ['regierung'] = {
        warning = true,
        pager = false,
        pagerOptions = {}
    }
}
```

Custom App is added to qs-smatrphone `config.lua` like this
```
[18] = {
	custom = true,
	app = "emergency",
	color = "./img/apps/dispatch.png",
	tooltipText = "Notruf",
	job = false,
	slot = 18,
	blockedjobs = {},
	Alerts = 0
},
```

### To-Do

Refactor html file and split into JS/CSS/HTML