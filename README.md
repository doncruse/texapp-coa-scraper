# Texas COA Op Scraper - a gem for Texas courts of appeals

### What's this about?

This gem understands how to parse the opinion lists released by each of Texas's fifteen intermediate courts of appeals.

### Why does this gem exist?

Originally, it was developed as part of the TexApp.org project ([github](http://github.com/texapp)), which was an effort to ensure that Texas's court of appeals opinions are available in a reliable &mdash; and citable &mdash; location available to the general public, members of the bar, and the court system itself.

In Texas, unpublished decisions of intermediate courts of appeals are precedential. Yet litigants do not always have a reliable way to locate or cite this authority. In the past, it was possible to use a well-crafted Google search to locate relevant opinions (a technique discussed in [this 2009 blog post](http://www.scotxblog.com/practice-notes/researching-unpublished-coa-opinions-in-texas/)). But with the courts' new TAMES system, these Google searches no longer worked.  The TAMES system does provide many of these opinions in an online archive, but its URLs are prohibitively long and complex to include in any printed legal brief.

### How can I use this?

This gem can be folded into the application of your choice to store information about these opinions or queue up downloads of the opinions themselves.  It does not contain code related to data storage or any interface to a file storage service.  Those implementation details are up to you.

The simplest way to use this gem is to specify a particular court of appeals (using its two-digit numerical notation, like "03" for the Third Court) and a particular date on which you want to check for opinions.  The gem will then determine the correct URL to use, check that page, and parse what is found to retrieve the metadata for each opinion released on that date.  What you get back is a list of that metadata.

The data for each opinion is a simple hash.  The overall set of results is just an array of those hashes, or an empty array if no results were found for that page. Here is an example of the hash for one opinion:

```ruby

CoaOpScraper.scrape_one_opinion_list("15", Date.new(2026, 6, 30)) => 
[ 
	{ release_date: <Date: 2026-06-30>, 
	  opinion_urls: { 
	  	"pdf" => "SearchMedia.aspx?MediaVersionID=fedbe1e1-858d-4f4e-9789-a5c9c72e06b8&MediaID=d5a912a7-6501-4e41-857a-edbda875f195&coa=coa15&DT=Opinion" }, 
		docket_no:  "15-25-00164-CV",
		docket_page_url: "Case.aspx?cn=15-25-00164-CV", 
		author_string: "Memorandum Opinion by Justice Farris", 
		panel_string: "Chief Justice Brister,Justice Field,Justice Farris",
		disposition: "reversed and remanded", 
		case_style: "Interra Credit Union v. Enrique Figueroa Laboy", 
		origin: "Appeal from 395th District Court of Williamson County" },
	
	{...},
	
	{...}
]
```

(The date is a Ruby date object, that should be easy for the code that uses this gem to adapt into the format of your liking.)

It's up to you to write code that does something interesting with that metadata &mdash; such as storing it or downloading the opinion PDFs themselves.

## Copyright

Copyright (c) 2013-2026 Don Cruse. See LICENSE.txt for further details.