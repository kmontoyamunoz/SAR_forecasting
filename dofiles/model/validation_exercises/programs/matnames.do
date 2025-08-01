*! matnames 1.01 11july2009 took out eval =
*! matnames 1.0 16apr2009
*! Program to put row and column names in r()
*! posted to Statalist by Austin Nichols 16 April 2009
capture program drop matnames
capture mata : mata drop getRNames()
capture mata : mata drop getCNames()
prog matnames, rclass
 version 9.2
 syntax anything [, *]
 cap conf matrix `anything'
 if _rc {
  di as err "matrix `anything' not found"
  error 198
  }

 loc y = rowsof(`anything')
 loc y = `y'-1
 forv i=1/`y' {
  mata: getRNames("`anything'",`i')
  loc r `"`r' `"`r1' `r2'"'"'
  }

 loc t = colsof(`anything')
 loc t = `t'-1
 forv i=1/`t' {
  mata: getCNames("`anything'",`i')
  loc c `"`c' `"`r1' `r2'"'"'
  }
 return local r `"`r'"'
 return local c `"`c'"'
end
version 9.2
mata:
 void getRNames(string scalar b, real scalar i)
 {
   r=st_matrixrowstripe(b)
   st_local("r1", r[i,1])
   st_local("r2", r[i,2])
 }
 void getCNames(string scalar b, real scalar i)
 {
   c=st_matrixcolstripe(b)
   st_local("r1", c[i,1])
   st_local("r2", c[i,2])
 }
end
