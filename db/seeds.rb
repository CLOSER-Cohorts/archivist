# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# <<< Creating User Groups >>>
#
g1 = UserGroup.create(id: 1, group_type: "Centre", label: "CLOSER", study: "*")
g2 = UserGroup.create(id: 2, group_type: "Centre", label: "ISER", study: "US")
g3 = UserGroup.create(id: 3, group_type: "Study", label: "ALSPAC", study: "ALSPAC")
g4 = UserGroup.create(id: 4, group_type: "Centre", label: "CLS", study: ["BCS", "MCS", "NCDS"])
g5 = UserGroup.create(id: 5, group_type: "Study", label: "NSHD", study: ["NSHD"])
g6 = UserGroup.create(id: 6, group_type: "Centre", label: "SOTON", study: ["HCS", "SWS", "HEAF"])
g7 = UserGroup.create(id: 7, group_type: "Centre", label: "UKDS", study: ["UKDS", "BCS", "MCS", "NCDS", "CLOSER", "US", "ALSPAC", "SWS", "HCS", "NSHD"])
g8 = UserGroup.create(id: 8, group_type: "Study", label: "Whitehall II", study: "WHII")

# <<< End of Creating User Groups >>>

# <<< Creating Users >>>
#
# If you need more users, simply copy and paste the code below and edit new users details accordingly.
# confirmation_tokens must be unique
# Roles: 'admin', 'reader', or 'editor'

# Admin user
admin1 = User.create( id: 1, email: "admin1@email.com", first_name: "Admin", last_name: "One", group_id: 1, role: "admin", password: "Password123", password_confirmation: "Password123", confirmation_token: 'XM2oSPVexoYNkHhzYJqk', confirmed_at: Time.now )

# Reader user
reader1 = User.create( id: 2, email: "reader1@email.com", first_name: "Reader", last_name: "One", group_id: 1, role: "reader", password: "Password123", password_confirmation: "Password123", confirmation_token: 'xPT8fwPsA6Nr_vJgz3SD', confirmed_at: Time.now )
#
# Editor
editor1 = User.create( id: 3, email: "editor1@email.com", first_name: "Editor", last_name: "One", group_id: 1, role: "editor", password: "Password123", password_confirmation: "Password123", confirmation_token: 'G9E3uVfnyn2C3zzGZHzY', confirmed_at: Time.now )
# <<< End of Creating Users >>>


# <<< Creating Topics >>>
#
t0 = Topic.create( id: 0, name: 'None', code: '000' )
t1 = Topic.create( id: 1, name: 'Demographics', code: '101' )
t2 = Topic.create( id: 2, name: "Housing and local environment (Housing and environ...', code: '102 ', description: 'Housing = Living facilities for humans.\nEnvironmen..." )
t3 = Topic.create( id: 3, name: 'Physical health ', code: '103 ', description: 'Health relating to the body as opposed to the mind...' )
t4 = Topic.create( id: 4, name: 'Mental health and mental processes', code: '104 ', description: 'Mental health = A person‚Äôs condition with regard t...' )
t5 = Topic.create( id: 5, name: 'Health care ', code: '105 ', description: 'The organized provision of medical care to individ...' )
t6 = Topic.create( id: 6, name: 'Health behaviour (Health and lifestyle) ', code: '106 ', description: 'Behaviors expressed by individuals to protect, mai...' )
t7 = Topic.create( id: 7, name: 'Family and social networks', code: '107 ', description: 'Family = A social group consisting of parents or p...' )
t8 = Topic.create( id: 8, name: 'Education', code: '108 ', description: 'Acquisition of knowledge as a result of instructio...' )
t9 = Topic.create( id: 9, name: 'Employment and income (Employment and pensions) ', code: '109 ', description: 'Employment = The state of being engaged in an acti...' )

t10 = Topic.create( id: 10, name: 'Expectations, attitudes and beliefs (Attitudes and...', code: '110 ', description: 'Expectation = A strong belief that something will ...' )
t11 = Topic.create( id: 11, name: 'Child development', code: '111 ', description: 'The continuous sequential physiological and psycho...' )
t12 = Topic.create( id: 12, name: 'Life events ', code: '112 ', description: "Any significant event in a person's life that may ..." )
t13 = Topic.create( id: 13, name: 'Omics', code: '113 ', description: 'Suffix forming nouns used to denote rigorous, syst...' )
t14 = Topic.create( id: 14, name: 'Pregnancy', code: '114 ', description: 'The status during which female mammals carry their...' )
t15 = Topic.create( id: 15, name: 'Administration', code: '115' )
t19 = Topic.create( id: 19, name: 'Place of birth', parent_id: 1, code: '10101' )
t20 = Topic.create( id: 20, name: 'Gender', parent_id: 1, code: '10102', description: "A person's concept of self as being male and mascu..." )
t21 = Topic.create( id: 21, name: 'Ethnic group', parent_id: 1, code: '10103', description: 'A group of people with a common cultural heritage ...' )
t22 = Topic.create( id: 22, name: 'Language(s) spoken', parent_id: 1, code: '10104', description: 'Language = The method of human communication, eith...' )
t23 = Topic.create( id: 23, name: 'Religion', parent_id: 10, code: '11003', description: '¬†A set of beliefs concerning the true nature, caus... ' )
t24 = Topic.create( id: 24, name: 'Location', parent_id: 1, code: '10106', description: 'A particular place or position. (Oxford online)' )
t25 = Topic.create( id: 25, name: 'Housing', parent_id: 2, code: '10201', description: 'Living facilities for humans. (MeSH)' )
t26 = Topic.create( id: 26, name: 'Neighbourhood', parent_id: 2, code: '10202', description: 'A district or community within a town or city. (Ox...' )
t27 = Topic.create( id: 27, name: 'Travel and transport', parent_id: 2, code: '10203', description: 'Travel = Make a journey, typically of some length....' )
t28 = Topic.create( id: 28, name: 'Environmental exposure', parent_id: 2, code: '10204', description: 'The exposure to potentially harmful chemical, phys...' )
t29 = Topic.create( id: 29, name: 'Residential mobility', parent_id: 2, code: '10205', description: 'Frequent change of residence, either in the same c...' )

t30 = Topic.create( id: 30, name: 'Cardiovascular system', parent_id: 3, code: '10301', description: 'The¬†heart and the blood vessels by which blood is ... ' )
t31 = Topic.create( id: 31, name: 'Musculoskeletal system', parent_id: 3, code: '10302', description: 'The muscles, bones (bone and bones), and cartilage...' )
t32 = Topic.create( id: 32, name: 'Respiratory system', parent_id: 3, code: '10303', description: 'The tubular and cavernous organs and structures, b...' )
t33 = Topic.create( id: 33, name: 'Nervous system', parent_id: 3, code: '10304', description: 'The entire nerve apparatus, composed of a central ...' )
t34 = Topic.create( id: 34, name: 'Digestive system', parent_id: 3, code: '10305', description: 'A group of organs stretching from the mouth to the...' )
t35 = Topic.create( id: 35, name: 'Urogenital system', parent_id: 3, code: '10306', description: 'All the organs involved in reproduction and the fo...' )
t36 = Topic.create( id: 36, name: 'Endocrine system', parent_id: 3, code: '10307', description: 'The systems of glands that release their secretion...' )
t37 = Topic.create( id: 37, name: 'Hemic and immune systems', parent_id: 3, code: '10308', description: 'Hemic = relating to the blood or circulatory syste...' )
t38 = Topic.create( id: 38, name: 'Hearing, vision, speech', parent_id: 3, code: '10309', description: 'Hearing = The faculty of perceiving sounds. (Oxfor...' )
t39 = Topic.create( id: 39, name: 'Oral/dental health', parent_id: 3, code: '10310', description: 'The optimal state of the mouth and normal function...' )

t40 = Topic.create( id: 40, name: 'Skin diseases | Dermatology', parent_id: 3, code: '10311', description: 'Dermatology = the medical speciality concerned wit...' )
t41 = Topic.create( id: 41, name: 'Congenital malformations', parent_id: 3, code: '10312', description: 'Malformations of organs or body parts during devel...' )
t42 = Topic.create( id: 42, name: 'Cancer', parent_id: 3, code: '10313', description: 'New abnormal growth of tissue. Malignant neoplasms...' )
t43 = Topic.create( id: 43, name: 'Mortality', parent_id: 3, code: '10314', description: 'All deaths reported in a given population. (MeSH)' )
t44 = Topic.create( id: 44, name: "Reproductive health', parent_id: 3, code: '10315', description: 'Within the framework of WHO's definition of health..." )
t45 = Topic.create( id: 45, name: "Women's health', parent_id: 3, code: '10316', description: 'A broad category of illnesses and¬†health¬†condition..." )
t46 = Topic.create( id: 46, name: 'Accidents and injuries', parent_id: 3, code: '10317', description: 'Damage inflicted on the body as the direct or indi...' )
t47 = Topic.create( id: 47, name: 'Allergies', parent_id: 3, code: '10318', description: 'Altered reactivity to an antigen, which can result...' )
t48 = Topic.create( id: 48, name: 'Infections', parent_id: 3, code: '10319', description: 'Invasion of the host organism by microorganisms th...' )
t49 = Topic.create( id: 49, name: 'Anthropometry', parent_id: 3, code: '10320', description: 'The technique that deals with the measurement of t...' )

t50 = Topic.create( id: 50, name: 'Physical characteristics', parent_id: 3, code: '10321', description: 'Pertaining to the body, rather than the mind. (Oxf...' )
t51 = Topic.create( id: 51, name: 'Physical functioning', parent_id: 3, code: '10322' )
t52 = Topic.create( id: 52, name: 'General health', parent_id: 3, code: '10323', description: 'The level of health of the individual, group, or p...' )
t53 = Topic.create( id: 53, name: 'Mental disorders', parent_id: 4, code: '10401', description: 'Mental disorders comprise a broad range of problem...' )
t54 = Topic.create( id: 54, name: 'Personality | Temperament', parent_id: 4, code: '10402', description: 'Personality = behaviour -response patterns that ch...' )
t55 = Topic.create( id: 55, name: 'Wellbeing', parent_id: 4, code: '10403', description: 'The state of being comfortable, healthy, or happy....' )
t56 = Topic.create( id: 56, name: 'Emotions', parent_id: 4, code: '10404', description: 'Those affective states which can be experienced an...' )
t57 = Topic.create( id: 57, name: 'Cognitive function', parent_id: 4, code: '10405', description: 'A set of cognitive functions that controls complex...' )
t58 = Topic.create( id: 58, name: 'Health services utilisation', parent_id: 5, code: '10501', description: 'The degree to which individuals are inhibited or f...' )
t59 = Topic.create( id: 59, name: 'Hospital admissions', parent_id: 5, code: '10502', description: 'The process of accepting patients. The concept inc...' )

t60 = Topic.create( id: 60, name: "Immunisations', parent_id: 5, code: '10503', description: 'Deliberate stimulation of the host's immune respon..." )
t61 = Topic.create( id: 61, name: 'Medications', parent_id: 5, code: '10504', description: 'Drugs intended for human or veterinary use, presen...' )
t62 = Topic.create( id: 62, name: 'Complementary therapies', parent_id: 5, code: '10505', description: 'Therapeutic practices which are not currently cons...' )
t63 = Topic.create( id: 63, name: 'Health insurance', parent_id: 5, code: '10506', description: 'Insurance providing coverage of medical, surgical,...' )
t64 = Topic.create( id: 64, name: 'Diet and nutrition', parent_id: 6, code: '10601', description: 'Diet = The kinds of food that a person, animal, or...' )
t65 = Topic.create( id: 65, name: 'Physical activity', parent_id: 6, code: '10602', description: 'Physical activity which is usually regular and don...' )
t66 = Topic.create( id: 66, name: 'Sleep', parent_id: 6, code: '10603', description: 'A readily reversible suspension of sensorimotor in...' )
t67 = Topic.create( id: 67, name: 'Smoking', parent_id: 6, code: '10604', description: 'Inhaling and exhaling the smoke of burning¬†TOBACCO... ' )
t68 = Topic.create( id: 68, name: 'Alcohol consumption', parent_id: 6, code: '10605', description: 'Behaviors associated with the ingesting of alcohol...' )
t69 = Topic.create( id: 69, name: 'Substance abuse', parent_id: 6, code: '10606', description: 'Disorders related to substance abuse. (MeSH)' )

t70 = Topic.create( id: 70, name: 'Risk taking', parent_id: 6, code: '10607', description: 'Undertaking a task involving a challenge for achie...' )
t72 = Topic.create( id: 72, name: 'Sexual behaviour', parent_id: 6, code: '10609', description: 'Sexual activities of humans. (MeSH)' )
t73 = Topic.create( id: 73, name: 'Home life', parent_id: 7, code: '10701', description: 'A person‚Äôs family, personal relationships, and dom...' )
t74 = Topic.create( id: 74, name: 'Household composition', parent_id: 7, code: '10702', description: 'One person living alone; or a group of people (not...' )
t75 = Topic.create( id: 75, name: "Marital status', parent_id: 7, code: '10703', description: 'A demographic parameter indicating a person's stat..." )
t76 = Topic.create( id: 76, name: 'Family members and relations', parent_id: 7, code: '10704', description: 'Behavioral, psychological, and social relations am...' )
t77 = Topic.create( id: 77, name: 'Friends', parent_id: 7, code: '10705', description: 'Persons whom one knows, likes, and trusts. (MeSH)' )
t79 = Topic.create( id: 79, name: 'Childcare', parent_id: 7, code: '10706', description: 'Care of children in the home or institution. (MeSH...' )

t80 = Topic.create( id: 80, name: 'Child welfare', parent_id: 7, code: '10707', description: 'Organized efforts by communities or organizations ...' )
t81 = Topic.create( id: 81, name: 'Social support', parent_id: 7, code: '10708', description: 'Support systems that provide assistance and encour...' )
t82 = Topic.create( id: 82, name: 'Leisure activities', parent_id: 7, code: '10709', description: 'Voluntary use of free time for activities outside ...' )
t83 = Topic.create( id: 83, name: 'Qualifications', parent_id: 8, code: '10801', description: 'A pass of an examination or an official completion...' )
t85 = Topic.create( id: 85, name: 'Further education | Higher education', parent_id: 8, code: '10803', description: 'FE:A sector which encompasses all post‚Äêcompulsory ...' )
t86 = Topic.create( id: 86, name: 'Training', parent_id: 8, code: '10804', description: 'The action of teaching a person or animal a partic...' )
t87 = Topic.create( id: 87, name: 'Basic skills', parent_id: 8, code: '10805', description: 'Defines basic skills as ‚ÄòThe ability to read, writ...' )
t88 = Topic.create( id: 88, name: 'Adult education', parent_id: 8, code: '10806', description: 'Courses of study offered for learners over the age...' )
t89 = Topic.create( id: 89, name: 'Learning difficulties', parent_id: 8, code: '10807', description: 'Difficulties in acquiring knowledge and skills to ...' )

t90 = Topic.create( id: 90, name: 'Pre-school', parent_id: 8, code: '10808', description: 'Relating to the time before a child is old enough ...' )
t91 = Topic.create( id: 91, name: "Cognitive function', parent_id: 8, code: '10809', description: 'Cognitive = related to cognition.\nCognition = The ... " )
t92 = Topic.create( id: 92, name: 'Cognitive skills', parent_id: 8, code: '10810', description: 'Skills acquired through cognition. (Oxford Online) ' )
t93 = Topic.create( id: 93, name: 'Non cognitive skills', parent_id: 8, code: '10811', description: 'A state of mind is non-cognitive if it involves no...' )
t94 = Topic.create( id: 94, name: 'School engagement', parent_id: 8, code: '10812' )
t95 = Topic.create( id: 95, name: 'Education aspirations', parent_id: 8, code: '10813', description: 'Aspiration = A hope or ambition of achieving somet...' )
t96 = Topic.create( id: 96, name: 'Lifelong learning', parent_id: 8, code: '10814', description: 'A form of or approach to education which promotes ...' )
t97 = Topic.create( id: 97, name: 'Occupation | Employment', parent_id: 9, code: '10901', description: 'Occupation = Crafts, trades, professions, or other...' )
t98 = Topic.create( id: 98, name: 'Social classification', parent_id: 9, code: '10902', description: 'A stratum of people with similar position and pres...' )
t99 = Topic.create( id: 99, name: 'Income', parent_id: 9, code: '10903', description: 'Revenues or receipts accruing from business enterp...' )

t100 = Topic.create( id: 100, name: 'Finances', parent_id: 9, code: '10904', description: 'The monetary resources and affairs of a state, org...' )
t101 = Topic.create( id: 101, name: 'Assets', parent_id: 9, code: '10905', description: 'A useful or valuable thing or person. (Oxford Onli...' )
t102 = Topic.create( id: 102, name: 'Consumption | Expenditure', parent_id: 9, code: '10906', description: 'The action of using up a resource. The action of s...' )
t103 = Topic.create( id: 103, name: 'Pensions', parent_id: 9, code: '10907', description: 'A regular payment made by the state to people of o...' )
t104 = Topic.create( id: 104, name: 'Infant feeding', parent_id: 11, code: '11101', description: 'The provision of breast milk, or a bottle substitu...' )
t105 = Topic.create( id: 105, name: 'Language and vocabulary', parent_id: 11, code: '11102', description: 'The gradual expansion in complexity and meaning of...' )
t106 = Topic.create( id: 106, name: 'Parenting', parent_id: 11, code: '11103', description: 'Performing the role of a parent by care-giving, nu...' )
t107 = Topic.create( id: 107, name: 'Developmental milestones', parent_id: 11, code: '11104', description: 'Skills gained by a developing child, which should ...' )
t108 = Topic.create( id: 108, name: 'Genetics', parent_id: 13, code: '11301', description: 'The branch of science concerned with the means and...' )
t109 = Topic.create( id: 109, name: 'Genomics', parent_id: 13, code: '11302', description: 'The systematic study of the complete¬†DNA¬†sequences...' )

t110 = Topic.create( id: 110, name: 'Transcriptomics', parent_id: 13, code: '11303', description: 'The study of transcriptomes and their functions. (...' )
t111 = Topic.create( id: 111, name: 'Metabolomics', parent_id: 13, code: '11304', description: 'The systematic identification and quantitation of ...' )
t112 = Topic.create( id: 112, name: 'Epigenomics', parent_id: 13, code: '11305', description: 'The systematic study of the global gene expression...' )
t113 = Topic.create( id: 113, name: 'Proteomics', parent_id: 13, code: '11306', description: 'The systematic study of the complete complement of...' )
t114 = Topic.create( id: 114, name: 'Age', parent_id: 1, code: '10107' )
t115 = Topic.create( id: 115, name: 'Social capital', parent_id: 7, code: '10710', description: 'The expected benefits derived from the cooperation...' )
t116 = Topic.create( id: 116, name: 'Technology', parent_id: 7, code: '10711' )
t117 = Topic.create( id: 117, name: 'Primary schooling', parent_id: 8, code: '10815' )
t118 = Topic.create( id: 118, name: 'Secondary schooling', parent_id: 8, code: '10816' )
t119 = Topic.create( id: 119, name: 'Benefits | Welfare', parent_id: 9, code: '10908' )

t120 = Topic.create( id: 120, name: 'Social attitudes', parent_id: 10, code: '11001', description: 'Attitude = The way in which a person views and eva...' )
t121 = Topic.create( id: 121, name: 'Politics', parent_id: 10, code: '11002' )
t122 = Topic.create( id: 122, name: 'Retirement', parent_id: 12, code: '11201' )
t123 = Topic.create( id: 123, name: 'Childbirth', parent_id: 14, code: '11401', description: 'The process of giving birth to one or more offspri...' )
t124 = Topic.create( id: 124, name: 'Infant mortality', parent_id: 14, code: '11402' )

# <<< end of Creating Topics >>>
