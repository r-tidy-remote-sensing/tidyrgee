## R CMD check results  

Run on 2022-09-13

-- R CMD check results ------------------------------------------- tidyrgee 0.1.0 ----
Duration: 58.1s

0 errors √ | 0 warnings √ | 0 notes √


There were no ERRORs , NOTEs or WARNINGs. 

## Downstream dependencies  

There are currently no downstream dependencies for this package.  

## Notes
Below I have quoted and numbered CRAN feedback from the first submission. Below each number point I have provided a response/explanation

1. "Please omit the redundant "in R" in your description."" 
1 response: **DONE**

2. "Please provide a link to the used webservices (Earth Engine) to the
description field
of your DESCRIPTION file in the form
<http:...> or <https:...>
with angle brackets for auto-linking and no space after 'http:' and
'https:'."" 

2 response: **DONE**

3. "Please write TRUE and FALSE instead of T and F.""
3 response: **DONE**

4. "Please don't use "T" or "F" as vector names.
'T' and 'F' instead of TRUE and FALSE:
   man/clip.Rd:
     clip(x, y, return_tidyee = T)
   man/filter_bounds.Rd:
     filter_bounds(x, y, use_tidyee_index = F, return_tidyee = T)
   man/summarise.Rd:
     {summarise}{ee.imagecollection.ImageCollection}(.data, stat, ...)
     {summarise}{tidyee}(.data, stat, ..., join_bands = T)""

4 response:**DONE**

5. "We see:      Unexecutable code in man/set_idx.Rd
Please look into this.

\dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...) by
the user. That's why wrapping examples in \dontrun{} adds the comment
("# Not run:") as a warning for the user.
Does not seem necessary.
Please replace \dontrun with \donttest.

Please unwrap the examples if they are executable in < 5 sec, or replace
\dontrun{} with \donttest{}."

5 **Explanation:** Our package relies on API codes so the functions cannot be run. 
For this reason we think `\dontrun{}` is the best option for `@examples`

6. "You write information messages to the console that cannot be easily
suppressed.
It is more R like to generate objects that can be used to extract the
information a user is interested in, and then print() that object.
Instead of print()/cat() rather use message()/warning() or
if(verbose)cat(..) (or maybe stop()) if you really have to write text to
the console.
(except for print, summary, interactive functions)"

6 response: **DONE** - changed all `cat()` and `print()` calls to message

7. "Please do not modify the global environment (e.g. by using <<-) in your
functions. This is not allowed by the CRAN policies. -> R/zzz.R"

7 response: **DONE:* This file has been removed after being deemed unnecessary

Please fix and resubmit.
**DONE**

## Run on 2022-09-14
-- R CMD check results -------------------------------------------------------------------------- tidyrgee 0.1.0 ----
Duration: 1m 49.8s

0 errors √ | 0 warnings √ | 0 notes √

