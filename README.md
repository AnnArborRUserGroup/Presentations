# About

This is the official repository for [Ann Arbor R User Group](http://www.meetup.com/Ann-Arbor-R-User-Group/) presentations.

# Presentation Guidelines

## Format

The preferred presentation format is an R Markdown document compiled to html. In this directory is a `template.Rmd` file which will help get you started making an ioslides presentation, the most commonly used format for this group.

Other presentation formats are allowed; please contact the group organizers to make sure they can accommodate your preferred format.

You can find out more about creating R Markdown files [here](http://rmarkdown.rstudio.com/).

## Adding your presentation

Fork this repository and add your files to a folder like `Presentations/yyyy-mm-dd/your-presentation-title` directory (where `yyyy-mm-dd` is the date of the meetup). Make as many commits as you like on any branch (`master` is fine), push those to Github, and then file a Pull Request to merge your branch into the `master` branch of the `AnnArborRUserGroup/Presentations` repository.

<br>

**If you run into trouble using creating or submitting your presentation, please contact the group organizers through Github, Meetup, or by email.**

## Tips

- If your code uses random number generation use the `set.seed()` function to make your results reproducible.

- If a function takes more than one argument, use the argument names for clarity. For example, use `foo(x = bar, y = qux, z = norf)` instead of `foo(bar, qux, norf)`. This is particularly important for functions that other useRs might not be familiar with. It isn't necessary to use argument names for functions that only take a single argument (ex. `head(x)`) or if you are only passing one argument to a function (ex. `print(x)`).

- Try to maintain the same coding style throughout. Consider taking a look at [Hadley Wickham's style guide](http://adv-r.had.co.nz/Style.html) for general guidelines.

