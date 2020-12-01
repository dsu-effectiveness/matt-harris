-- !preview conn=con

/*
This query pulls the contact information for adjunct faculty who have taught any
course since the 2018 academic year. The query also pulls the contact information
for the adjunct, as well as the time, meeting days, and courses taught.
*/

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
          COALESCE(l.sprtele_phone_area, '435') || '-' || l.sprtele_phone_number as phone
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
    WHERE a.sirasgn_posn IS NOT NULL
      AND d.stvterm_acyr_code >= 2018
      AND substr(sirasgn_posn, 1, 3) NOT IN ('GNC', 'GOL')
      AND b.nbbposn_ecls_code = 'AD'
      AND k.goremal_status_ind = 'A'
      AND k.goremal_disp_web_ind = 'Y'
