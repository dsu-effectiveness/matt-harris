-- !preview conn=con

/*
This query pulls the contact information for adjunct faculty who have taught any
course since the 2018 academic year. The query also pulls the contact information
for the adjunct, as well as the time, meeting days, and courses taught.
*/
WITH degree AS (
     SELECT DISTINCT
            a.sirasgn_pidm AS pidm,
            e.stvdegc_desc AS highest_degree_earned,
            e.stvdegc_dlev_code AS deg_level,
            CASE
                WHEN e.stvdegc_dlev_code = 'AS' THEN 1
                WHEN e.stvdegc_dlev_code = 'BA' THEN 2
                WHEN e.stvdegc_dlev_code = 'MA' THEN 3
                WHEN e.stvdegc_dlev_code = 'DR' THEN 4
                END AS deg_pref
       FROM sirasgn a
  LEFT JOIN ssbsect b
         ON b.ssbsect_term_code = a.sirasgn_term_code
        AND b.ssbsect_crn = a.sirasgn_crn
  LEFT JOIN sordegr d
         ON d.sordegr_pidm = a.sirasgn_pidm
        AND d.sordegr_degr_seq_no = (SELECT MAX(d1.sordegr_degr_seq_no)
                                       FROM sordegr d1
                                      WHERE d1.sordegr_pidm = d.sordegr_pidm)
  LEFT JOIN stvdegc e
         ON e.stvdegc_code = d.sordegr_degc_code
      WHERE a.sirasgn_posn IS NOT NULL
        AND a.sirasgn_suff IS NOT NULL
        AND a.sirasgn_posn NOT LIKE 'GNC%'
        AND b.ssbsect_enrl > 0
        AND e.stvdegc_dlev_code IS NOT NULL
)
   SELECT DISTINCT
          f.spriden_id AS dnumber,
          f.spriden_first_name,
          f.spriden_last_name,
          d.stvterm_acyr_code,
          d.stvterm_desc,
          h.ssbsect_subj_code,
          h.ssbsect_crse_numb,
          g.ssrmeet_mon_day || g.ssrmeet_tue_day || g.ssrmeet_wed_day || g.ssrmeet_thu_day || g.ssrmeet_fri_day || g.ssrmeet_sat_day AS days,
          g.ssrmeet_begin_time,
          g.ssrmeet_end_time,
          k.goremal_email_address,
          COALESCE(l.sprtele_phone_area, '435') || '-' || l.sprtele_phone_number as phone,
          m.highest_degree_earned
     FROM sirasgn a
LEFT JOIN nbbposn b
       ON b.nbbposn_posn = a.sirasgn_posn
LEFT JOIN ptrecls c
       ON c.ptrecls_code = b.nbbposn_ecls_code
LEFT JOIN stvterm d
       ON d.stvterm_code = a.sirasgn_term_code
LEFT JOIN spriden f
       ON f.spriden_pidm = a.sirasgn_pidm
LEFT JOIN ssrmeet g
       ON g.ssrmeet_term_code = a.sirasgn_term_code
      AND g.ssrmeet_crn = a.sirasgn_crn
LEFT JOIN ssbsect h
       ON h.ssbsect_term_code = a.sirasgn_term_code
      AND h.ssbsect_crn = a.sirasgn_crn
LEFT JOIN goremal k
       ON k.goremal_pidm = a.sirasgn_pidm
LEFT JOIN sprtele l
       ON l.sprtele_pidm = a.sirasgn_pidm
LEFT JOIN (SELECT m1.pidm,
                  m1.highest_degree_earned
             FROM degree m1
            WHERE m1.deg_pref = (SELECT MAX (m2.deg_pref)
                                   FROM degree m2
                                  WHERE m2.pidm = m1.pidm)
          ) m
       ON m.pidm = a.sirasgn_pidm
    WHERE a.sirasgn_posn IS NOT NULL
      AND d.stvterm_acyr_code >= 2018
      AND substr(sirasgn_posn, 1, 3) NOT IN ('GNC', 'GOL')
      AND b.nbbposn_ecls_code = 'AD'
      AND k.goremal_status_ind = 'A'
      AND k.goremal_disp_web_ind = 'Y'

--48350
