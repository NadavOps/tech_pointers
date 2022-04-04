Bash
===========

<!--ts-->
  * [Script Console](#script-console)
  * [Links](#links)
<!--te-->

Script Console
====
```
# Manage Jenkins -> Script Console
println(Jenkins.instance.getItemByFullName("job_name").getBuildByNumber(build_number)) -> print process
Jenkins.instance.getItemByFullName("job_name").getBuildByNumber(build_number).finish(hudson.model.Result.ABORTED, new java.io.IOException("Aborting build")); -> ending zombie process
```

Links
====
* [Jenkins zombie process](https://stackoverflow.com/questions/14456592/how-to-stop-an-unstoppable-zombie-job-on-jenkins-without-restarting-the-server/38481808#38481808)
* [Jenkins simulations](https://jenkinsci.github.io/job-dsl-plugin/#method/javaposse.jobdsl.dsl.helpers.wrapper.WrapperContext.colorizeOutput)