# bridge_drifttuner
On demand drift tuning by vehicle class with database support.

Thank you for considering trying my resource!

This resource is provided free of charge and without support.

You are permitted to modify to your liking and distribute, please just credit original authors.

Database
CREATE TABLE IF NOT EXISTS bridge_drifttuner ( plate varchar(50) DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

Shared/Items.lua
['drifttuner'] 				 = {['name'] = 'drifttuner', 			    	['label'] = 'Drift Tuner', 				['weight'] = 2000, 		['type'] = 'item', 		['image'] = 'tunerchip.png', 			['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,	['description'] = 'Lets get drifty!'},
Function for PD to check turbo and drift modification status
bridge_drifttuner:TuneStatus

https://github.com/MoravianLion/Drift-Script
