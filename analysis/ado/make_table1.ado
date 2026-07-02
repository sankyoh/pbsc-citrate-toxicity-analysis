*! make_table1.ado  v1.2.1  01jun2026
program define make_table1
    version 18.0

    // varlist may include i. factor-variable notation (fv).
    // [weight] is also accepted (pweight/aweight/fweight/iweight).
    syntax varlist(fv) [if] [in] [fweight aweight pweight iweight], ///
        BY(name) ///
        SDVARS(varlist numeric) ///
        [ IQRVARS(varlist numeric) ] ///
        WRITEFILE(string asis)

    // IMPORTANT:
    // For a descriptive Table 1, observations should NOT be excluded simply
    // because one of the listed variables is missing.
    // The previous version used:
    //     marksample touse, strok
    // which marks out any observation with missing values in any variable in
    // varlist. With many variables, and especially with sex-specific structural
    // missing values such as .a, this can reduce the analytic sample to zero
    // and lead to "no observations" from dtable.
    //
    // novarlist keeps only the if/in restriction in touse and leaves
    // variable-specific missingness to dtable.
    marksample touse, novarlist strok

    // --------------------------
    // 0) Handle weights (build option strings).
    // --------------------------
    local wopt ""
    local wnoteopt ""
    local wfmtopt ""

    if "`weight'" != "" {
        // Weight specification passed to dtable (e.g., [pweight=sw]).
        local wopt "[`weight'`exp']"

        // Extract only the expression from exp (remove =).
        local wexpr = strtrim(subinstr("`exp'", "=", "", .))

        // Exclude missing or nonpositive weights within the analysis sample (safety check).
        quietly count if `touse' & missing(`wexpr')
        if r(N) > 0 {
            di as error "The analysis sample (including if/in restrictions) contains observations with missing weights: N=" r(N)
            exit 2000
        }
        quietly count if `touse' & (`wexpr'<=0)
        if r(N) > 0 {
            di as error "The analysis sample (including if/in restrictions) contains observations with weights <= 0: N=" r(N)
            exit 2000
        }

        // (1) Counts for categorical variables (factors) are returned as fvfrequency/fvrawfrequency.
        //     When weighted, counts may be non-integers; overwrite the format to show 2 decimals.
        // (2) By dtable design, the sample row is frequency when unweighted and sumw when weighted.
        //     Also show 2 decimals for this row when weighted.
        local wfmtopt ///
            "nformat(%16.2fc fvfrequency fvrawfrequency frequency sumw)"

        // (3) Automatically add a note only when weights are used.
        local wnoteopt "note("Weighted using `weight'`exp'")"
    }

    // --------------------------
    // 1) Pre-check: consistency between sdvars and iqrvars.
    // --------------------------
    local overlap : list sdvars & iqrvars
    if "`overlap'" != "" {
        di as error "sdvars() and iqrvars() overlap: `overlap'"
        exit 198
    }

    local allcont "`sdvars' `iqrvars'"

    // List raw variable names in varlist (remove prefixes such as i.).
    local rawvars ""
    foreach tok of local varlist {
        local base "`tok'"
        if strpos("`tok'", ".") {
            local base = substr("`tok'", strpos("`tok'", ".")+1, .)
        }
        // Split # as a precaution (normally not expected).
        local base2 : subinstr local base "#" " ", all
        foreach v of local base2 {
            local rawvars `rawvars' `v'
        }
    }
    local rawvars : list uniq rawvars

    // Check whether sdvars/iqrvars are included in des_vars.
    foreach v of local allcont {
        local pos : list posof "`v'" in rawvars
        if `pos'==0 {
            di as error "Continuous variable `v' is not included in des_vars(varlist)."
            di as error " -> Add `v' to des_vars without the i. prefix."
            exit 198
        }
    }

    // Check whether non-continuous variables are specified with i.
    // Return an error if a continuous variable is specified with i.
    foreach tok of local varlist {
        local base "`tok'"
        if strpos("`tok'", ".") {
            local base   = substr("`tok'", strpos("`tok'", ".")+1, .)
        }
        if strpos("`base'", "#") continue

        local posc : list posof "`base'" in allcont
        if `posc' > 0 {
            if substr("`tok'",1,2)=="i." {
                di as error "Continuous variable `base' is specified with factor notation (i.): `tok'"
                di as error " -> Remove i. or review the sdvars()/iqrvars() specification."
                exit 198
            }
        }
        else {
            if substr("`tok'",1,2)!="i." {
                di as error "Non-continuous variables must be specified as i.varname. Problem token: `tok'"
                di as error " -> If it is continuous, include it in sdvars() or iqrvars()."
                exit 198
            }
        }
    }

    // --------------------------
    // 2) Output filename
    // --------------------------
    local outfile `writefile'
    if !regexm(lower("`outfile'"), "\.xlsx$") {
        local outfile "`outfile'.xlsx"
    }

    // If iqrvars is empty, omit this option to avoid overwriting defaults for all continuous variables.
    local iqr_opt ""
    if "`iqrvars'" != "" {
        local iqr_opt `"`iqr_opt' continuous(`iqrvars', statistics(q2 iqi))"'
    }

    // --------------------------
    // 3) Main dtable command (conditionally add weights, formats, and notes).
    // --------------------------
    dtable `varlist' if `touse' `wopt', ///
        by(`by', nototals notests missing) ///
        column(by(label)) ///
        sample(, place(seplabels)) ///
        ///
        define(iqi = q1 q3, delimiter(", ")) ///
        sformat("[%s]" iqi) ///
        ///
        nformat(%16.2fc mean sd q1 q2 q3) ///
        `wfmtopt' ///
        continuous(`sdvars', statistics(mean sd) test(regress)) ///
        `iqr_opt' ///
        factor(, test(pearson)) ///
        ///
        note(Mean(SD) or N(%)) ///
        note(Median[IQR]) ///
        `wnoteopt' ///
        export("`outfile'", as(xlsx) replace)

end
