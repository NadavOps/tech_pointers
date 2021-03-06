# AWS

# Table of Content
* [RDS](#rds)
* [Links](#links)

# RDS
## Storage scaling conditions
Amazon RDS starts a storage modification for an autoscaling-enabled DB instance when these factors apply:  
1. Free available space is less than 10 percent of the allocated storage.
2. The low-storage condition lasts at least five minutes.
3. At least six hours have passed since the last storage modification, or storage optimization has completed on the instance, whichever is longer.

# Links

* [EC2 Instances info](https://https://instances.vantage.sh/).
