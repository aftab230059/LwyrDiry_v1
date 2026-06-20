// Shared case data + merge logic for Lawyers Diary.
// Mirrors the seed inside "Lawyers Diary.dc.html" and reads the SAME localStorage
// keys so the All-Cases page reflects edits / new cases / forwarded dates.
(function () {
  var LS_KEY = 'ld_diary_overrides_v2';

  function seedCases() {
    return [
      { id: 'c1', no: 'Title Suit 184/2024', type: 'Civil', clientKey: 'rahim', court: 'Joint District Judge, 3rd Court, Dhaka', courtShort: 'JDJ 3rd Ct, Dhaka', stage: 'Evidence (PW-2)', stageType: 'evidence', prevDate: '2026-04-22', nextDate: '2026-06-15',
        partiesA: [{ tag: 'A1', name: 'Md. Rahimullah', mine: true, phone: '+880 1711-204488' }, { tag: 'A2', name: 'Rahima Khatun', mine: true, phone: '+880 1733-551200' }],
        partiesB: [{ tag: 'B1', name: 'Shah Alam' }, { tag: 'B2', name: 'Korim Mia' }, { tag: 'B3', name: 'A.C. Land, Mirpur' }],
        summary: 'Declaration of title and permanent injunction over 12 katha of land at Mirpur; defendants dispute the 2019 mutation.' },
      { id: 'c2', no: 'Money Suit 56/2025', type: 'Civil', clientKey: 'sunrise', court: 'Joint District Judge, 1st Court, Dhaka', courtShort: 'JDJ 1st Ct, Dhaka', stage: 'Written Statement', stageType: 'pending', prevDate: '2026-03-30', nextDate: '2026-06-15',
        partiesA: [{ tag: 'A1', name: 'Sunrise Textiles Ltd.', mine: true, phone: '+880 1819-770312' }],
        partiesB: [{ tag: 'B1', name: 'Delwar Enterprise' }, { tag: 'B2', name: 'Md. Delwar Hossain' }],
        summary: 'Recovery of BDT 48,20,000 against supplied yarn under three invoices; defendant denies delivery.' },
      { id: 'c3', no: 'GR 412/2025', type: 'Criminal', clientKey: 'kamal', court: 'Chief Metropolitan Magistrate, Dhaka', courtShort: 'CMM, Dhaka', stage: 'Charge Hearing', stageType: 'hearing', prevDate: '2026-02-15', nextDate: '2026-06-15',
        partiesA: [{ tag: 'A1', name: 'State (Informant: Hasan Mahmud)' }],
        partiesB: [{ tag: 'B1', name: 'Kamal Hossain', mine: true, phone: '+880 1556-330921' }],
        summary: 'Sec. 420/406 of the Penal Code \u2014 alleged cheating in a flat booking. Accused on bail; charge framing pending.' },
      { id: 'c4', no: 'Family Suit 22/2026', type: 'Family', clientKey: 'tahmina', court: 'Family Court, Dhaka', courtShort: 'Family Ct, Dhaka', stage: 'Mediation', stageType: 'pending', prevDate: '2026-04-12', nextDate: '2026-06-16',
        partiesA: [{ tag: 'A1', name: 'Tahmina Begum', mine: true, phone: '+880 1733-118842' }],
        partiesB: [{ tag: 'B1', name: 'Rafiqul Islam' }],
        summary: 'Recovery of dower (denmohor) of BDT 6,00,000 with maintenance and custody of one minor child; mediation in progress.' },
      { id: 'c5', no: 'Writ Petition 6642/2025', type: 'Writ', clientKey: 'sunrise', court: 'High Court Division, Supreme Court', courtShort: 'High Court Division', stage: 'Rule Hearing', stageType: 'hearing', prevDate: '2026-05-11', nextDate: '2026-06-18',
        partiesA: [{ tag: 'A1', name: 'Sunrise Textiles Ltd.', mine: true, phone: '+880 1819-770312' }],
        partiesB: [{ tag: 'B1', name: 'Commissioner, VAT (NBR)' }, { tag: 'B2', name: 'Govt. of Bangladesh' }],
        summary: 'Challenge to a VAT demand order; interim stay obtained, Rule now returnable for final hearing.' },
      { id: 'c6', no: 'Sessions Case 305/2024', type: 'Criminal', clientKey: 'mannan', court: 'Metropolitan Sessions Judge, Dhaka', courtShort: 'Sessions Ct, Dhaka', stage: 'Examination of Witnesses', stageType: 'evidence', prevDate: '2026-03-05', nextDate: '2026-06-18',
        partiesA: [{ tag: 'A1', name: 'State (Victim: Sumon Mia)' }],
        partiesB: [{ tag: 'B1', name: 'Abdul Mannan', mine: true, phone: '+880 1612-559078' }],
        summary: 'Sec. 326 of the Penal Code \u2014 grievous hurt. Three prosecution witnesses examined; defence cross part-heard.' },
      { id: 'c7', no: 'Civil Revision 410/2024', type: 'Civil', clientKey: 'rahim', court: 'District Judge, Dhaka', courtShort: 'District Judge, Dhaka', stage: 'Argument', stageType: 'argument', prevDate: '2025-05-19', nextDate: '2026-06-23',
        partiesA: [{ tag: 'A1', name: 'Md. Rahimullah', mine: true, phone: '+880 1711-204488' }],
        partiesB: [{ tag: 'B1', name: 'Shah Alam' }],
        summary: 'Revision against rejection of a temporary injunction application in the connected title matter; arguments at final stage.' },
      { id: 'c8', no: 'CR 88/2026', type: 'Criminal', clientKey: 'nasrin', court: 'Chief Judicial Magistrate, Gazipur', courtShort: 'CJM, Gazipur', stage: 'Cognizance', stageType: 'pending', prevDate: '2026-05-15', nextDate: '2026-06-23',
        partiesA: [{ tag: 'A1', name: 'Nasrin Akter', mine: true, phone: '+880 1922-664410' }],
        partiesB: [{ tag: 'B1', name: 'Abul Kashem' }],
        summary: 'Sec. 138 of the Negotiable Instruments Act \u2014 dishonour of a cheque for BDT 3,50,000 after a valid notice.' },
      { id: 'c9', no: 'Criminal Appeal 1207/2023', type: 'Criminal', clientKey: 'mannan', court: 'High Court Division, Supreme Court', courtShort: 'High Court Division', stage: 'Awaiting Hearing', stageType: 'pending', prevDate: '2024-02-26', nextDate: '2026-06-22',
        partiesA: [{ tag: 'A1', name: 'State' }],
        partiesB: [{ tag: 'B1', name: 'Abdul Mannan', mine: true, phone: '+880 1612-559078' }],
        summary: 'Appeal against conviction u/s 379 of the Penal Code; sentence suspended and appellant on bail pending hearing.' },
      { id: 'c10', no: 'Chagolnaiya Deo-27/19', type: 'Civil', clientKey: 'nurul', court: 'Senior Assistant Judge Court, Chagolnaiya, Feni', courtShort: 'Sr. Asst. Judge, Chagolnaiya', stage: 'Filed', stageType: 'pending', prevDate: '', nextDate: '',
        partiesA: [{ tag: 'A1', name: 'Nurul Islam', mine: true, phone: '+880 1840-665522' }],
        partiesB: [{ tag: 'B1', name: 'Abdul Jalil' }, { tag: 'B2', name: 'Abdus Salam' }],
        summary: 'Partition suit (banton) over homestead land at Chagolnaiya; next date and plan not yet set.' },
      { id: 'c11', no: 'Title Execution 09/2025', type: 'Civil', clientKey: 'rahim', court: 'Joint District Judge, 2nd Court, Dhaka', courtShort: 'JDJ 2nd Ct, Dhaka', stage: 'Execution', stageType: 'pending', prevDate: '2026-05-13', nextDate: '2026-06-10',
        partiesA: [{ tag: 'A1', name: 'Md. Rahimullah', mine: true, phone: '+880 1711-204488' }],
        partiesB: [{ tag: 'B1', name: 'Shah Alam' }],
        summary: 'Execution of the decree in the connected title matter; last fixed date passed with no fresh date taken by the court.' }
    ];
  }

  function clients() {
    return {
      rahim:   { name: 'Md. Rahimullah', role: 'Plaintiff', phone: '+880 1711-204488' },
      sunrise: { name: 'Sunrise Textiles Ltd.', role: 'Petitioner', phone: '+880 1819-770312' },
      mannan:  { name: 'Abdul Mannan', role: 'Accused', phone: '+880 1612-559078' },
      kamal:   { name: 'Kamal Hossain', role: 'Accused (on bail)', phone: '+880 1556-330921' },
      tahmina: { name: 'Tahmina Begum', role: 'Petitioner', phone: '+880 1733-118842' },
      nasrin:  { name: 'Nasrin Akter', role: 'Complainant', phone: '+880 1922-664410' },
      nurul:   { name: 'Nurul Islam', role: 'Plaintiff', phone: '+880 1840-665522' }
    };
  }

  function getCases() {
    var seed = seedCases();
    var overrides = {}, added = [];
    try { overrides = JSON.parse(window.localStorage.getItem(LS_KEY) || '{}') || {}; } catch (e) {}
    try { added = JSON.parse(window.localStorage.getItem('ld_new_cases_v1') || '[]') || []; } catch (e) {}
    var base = seed.concat(added);
    return base.map(function (c) {
      var o = overrides[c.id];
      if (!o) return c;
      return Object.assign({}, c, {
        nextDate: o.nextDate != null ? o.nextDate : c.nextDate,
        prevDate: o.prevDate != null ? o.prevDate : c.prevDate,
        oppName: o.oppName != null ? o.oppName : c.oppName,
        oppPhone: o.oppPhone != null ? o.oppPhone : c.oppPhone
      });
    });
  }

  window.LD_DB = { getCases: getCases, clients: clients };
})();
