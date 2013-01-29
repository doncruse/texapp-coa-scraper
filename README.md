# Coa Op Scraper - a gem for Texas courts of appeals

### What's this about?

This gem understands how to parse the opinion lists released by each of
Texas's fourteen intermediate courts of appeals.

Opinion releases are announced on a separate webpage for each court of
appeals.  Some courts use a legacy system; others have shifted to the new
TAMES system employed by the Texas Supreme Court.

### Why does this gem exist?

It was developed as part of the TexApp.org project [github](http://github.com/texapp),
which aims to ensure that Texas's court of appeals opinions are available in
a reliable &mdash; and citable &mdash; location available to the general public,
members of the bar, and the court system itself.

In Texas, unpublished decisions of intermediate courts of appeals are precedential.
Yet litigants do not always have a reliable way to locate or cite this authority.
In the past, it was possible to use a well-crafted Google search to locate
relevant opinions (a technique discussed in [this 2009 blog post](http://www.scotxblog.com/practice-notes/researching-unpublished-coa-opinions-in-texas/)). But with the courts'
new TAMES system, these Google searches no longer work.  The TAMES system does provide
many of these opinions in an online archive, but its URLs are prohitively long and
complex to include in any printed legal brief.

### How can I use this?

This gem can be folded into the application of your choice to store 
information about these opinions or queue up downloads of the opinions
themselves.  It does not contain code related to data storage or any
interface to a file storage service.  Those implementation details
are up to you.

The simplest way to use this gem is to specify a particular court of appeals
(using its two-digit numberical notation, like "03" for the Third Court) and a
particular date on which you want to check for opinions.  The gem will then
determine the correct URL to use, check that page, and parse what is found to
retrieve the metadata for each opinion released on that date.  What you get back
is a list of that metadata.

The data for each opinion is a simple hash.  The overall
set of results is just an array of those hashes, or an empty array if no
results were found for that page. Here is an example of the hash for one opinion:

> { :author_string => "Opinion by Justice Pemberton", 
    :opinion_urls => {"html"=>"/opinions/htmlopinion.asp?OpinionId=20764", 
                      "pdf"=>"/opinions/PDFOpinion.asp?OpinionId=20764"},
    :disposition => "AFFIRMED:", 
    :panel_string => "(Before Chief Justice Jones, Justices Pemberton and Henson)", 
    :release_date => Fri, 20 Jan 2012, 
    :case_style => "Janeen Denise Smith v. The State of Texas", 
    :origin => "Appeal from County Court at Law No. 1 of Caldwell County", 
    :docket_no => "03-10-00725-CR", 
    :docket_page_url => "/opinions/case.asp?FilingID=15750" }

It's up to you to write code that does something interesting with that metadata &mdash;
such as storing it or downloading the opinion PDFs themselves (as is being done
for TexApp.org).

== Copyright

Copyright (c) 2013 Don Cruse. See LICENSE.txt for
further details.

