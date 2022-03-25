#Rapid-Response-Reporting
🔮RRR (Rapid Response Reporting) is a collection of Incident Response Report objects.  They are designed to help incident responders provide accurate and timely feedback in the form of reports.

🤠BLUF:  If your organization has a malware incident, based upon the malware family, you can quickly find:
🚨Mitigating Controls
🥳Recommendations
🚩Data Sources

🧐How does it work?:

Based upon the Malware family I collected the Mitre Att&CK TTPs and then pivoted to the defensive measures, data sources for detecting, and recommendations and joined those all into unique objects.

🤌These are provided in two formats:
1. CSV -  Need to give a quick update without a report?  This works for you.
2. Sankey Images - These vectorized graphics show "biggest bang for your buck" for each malware family.
  -> Moving left to right you have 🥇1. Defensive Control 🥈2. The concerned technique 🥉3. Data source required to detect said technique.
  
  <img width="851" alt="image" src="https://user-images.githubusercontent.com/93224853/160142902-57bf7b39-8646-4155-9da8-657d9b390f4d.png">


🙃BONUS: If you want the data in a preformatted Word Doc table that you can copy and paste simply run Create-Recommendations.

😍Due credits:  I got this idea from Andy Applebaum and Jamie Williams and the rest of the ATT&CK team based upon a series of blog post from back in 2019:
https://medium.com/mitre-attack/visualizing-attack-f5e1766b42a6 While it isn't an entirely novel idea (see the blog), it is the most complete corpus of malware family documents that I have found to date.

🤝Also this data was generated based off of https://github.com/nshalabi/ATTACK-Tools/.  Without @nshalabi's sql database, joining this data would have been much more difficult.

🚧Caution:
These were generated at a point in time and not evergreen.  Make sure to double check the output to ensure that it meets your needs and is taking into account any changes in the MITRE ATT&CK framework and/or developements in malware capabilities.  Regardles, they will get you really close and save you a bunch of time...which is the point.

🗿Why release them now:?
I previously worked for many years in a DFIR/CSIRT capability.  I now am working as a Senior Threat Researcher and it felt selfish to sit on this set of data.

👎I've also included my terrible Powershell script I used to produce them. It wasn't ever intended to see the light of day so I didn't follow any standards so please don't judge me.
