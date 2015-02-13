# Presentations

Repository for [Ann Arbor R User Group](http://www.meetup.com/Ann-Arbor-R-User-Group/) presentations.

## Instructions for new presenters

First time presenters should message an organizer to be added to the github organization. Clone the directory for the meetup you will be presenting at (e.g. `2015-03-12`). Create a new directory and add your content, including code, data, and output. Initiate a pull request when you have finished your presentation.

### Create reproducible presentations

Consider using RStudio, R Markdown, and knitr for your presentation. RStudio is an easy to use integrated development environment with built-in support for R Markdown. R Markdown and knitr are powerful tools for combining code, output, and text into documents and presentation slides.

If your code uses random number generation use the `set.seed()` function to make your results reproducible.

If you use data, include it in your commit.

### Git

Clone the github repository and 

    $ git clone https://github.com/AnnArborRUserGroup/Presentations.git
    $ cd Presentations/
    $ git branch my-presentation-branch
    $ git checkout my-presentation-branch

Make your presentation or add your files to the directory. When you are ready, commit your files locally and push your branch to github.

    $ git commit -a -m "add your message here"
    $ git push -u origin my-presentation-branch