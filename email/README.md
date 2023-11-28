# Email

### Table of Content
* [Untitled](#untitled)
* [Links](#links)

## Untitled
```bash
# SPF record
"v=spf1 include:_spf.google.com ~all"

# DMARC record
# DMARC, which stands for Domain-based Message Authentication, Reporting, and Conformance, is a DNS TXT record that can be published for a domain to control what happens if a message fails authentication (i.e., the recipient server can't verify that the message's sender is who they say they are). A published DMARC record basically serves two purposes:

# Tells the recipient server to either: Quarantine the message, Reject the message, or Allow the message to continue delivery
# Sends reports to an email address or addresses with data about all the messages seen from the domain
"v=DMARC1; p=none; sp=none; fo=1; pct=100; rua=mailto:dmarc@example.com; ruf=mailto:dmarc@example.com"
```

## Links
* Scanners
    * [mxtoolbox](https://mxtoolbox.com/)
        * [mxtoolbox-dmarc](https://mxtoolbox.com/dmarc.aspx)
        * [mxtoolbox-spf](https://mxtoolbox.com/spf.aspx)
    * [caniphish](https://caniphish.com/free-phishing-tools/email-spoofing-test/)
    * [dmarctester](https://www.dmarctester.com)
* Google email security
    * [Help prevent spoofing, phishing, and spam](https://support.google.com/a/topic/9061731?hl=en&ref_topic=9202&sjid=14431166746603195570-EU)
    * [Tutorial: Recommended DMARC rollout](https://support.google.com/a/answer/10032473)
    * [arc email auth](https://support.google.com/a/answer/13198639)
* [easydmarc](https://easydmarc.com/blog/category/blog/email-security/)
* [dmarc-spf-hard-soft-fail](https://knowledge.ondmarc.redsift.com/en/articles/1148885-spf-hard-fail-vs-spf-soft-fail#h_f84814081d)
* [spf-dmarc](https://knowledge.broadcom.com/external/article/233661/how-spf-dmarc-and-dkim-work-in-emailclou.html)
* [Why is DMARC failing when SPF and DKIM are passing?](https://security.stackexchange.com/questions/215635/why-is-dmarc-failing-when-spf-and-dkim-are-passing)
* [SPF hard fail or soft fail](https://www.mailhardener.com/blog/why-mailhardener-recommends-spf-softfail-over-fail)
