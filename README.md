wikihistory
-----------

The goal of this project is to create a visualization of the edit history of any wikipedia page.
The current approach will be to use a Sankey diagram to visualize the edits, which will concretely
be implemented in D3.  The backend will be powered by a rails app that fetches the history data
via the MediaWiki API.

**Data From Each Edit**

Would like the following:

1.  Timestamp of edit
2.  User who performed the edit
3.  Diff in size of edit (e.g. +95 Mb, -10 Mb, etc.)

4.  Section where the edit was made
5.  The size of text added in addition to the text subtracted
6.  The actual diff (what is the easiest way to store this?)
7.  Whether the edit was later reverted as vandalism
8.  Summary comment
9.  Size of the article at that time (to ensure consistency)

**Potential Challenges**

1.  Getting the data in structured format (may require reformatting)
2.  Visualizing in a readable way for articles with a large number of edits
3.  May want to cache data in a smart way, especially for large articles

**Questions**

1.  Do I want to do something interesting with reverted changes?
2.  What should color represent (type of user -- bot, IP, official user)
3.  Associate some "controversy index" or measure of activity with this data?

