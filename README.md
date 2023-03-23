# Visualisation de données : census-income

## Introduction

Extrait du recensement de la population américaine effectué en 1994-1995, ce jeu de données contient les données d’un peu moins de 200 000 individus, réparties sur 40 variables. Ce jeu de données provient du Département du Commerce des Etats-Unis; nous sommes donc en présence de données qui s'attachent principalement à décrire des données démographiques et sur l'emploi.

Il est disponible sur le site de l'[UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/Census-Income+%28KDD%29).



### Données

Ce dataset contient 199 523 observations et 42 variables. 

Pour chaque variable, les personnes recensées les ont remplies si elles étaient concernées. La liste des variables est la suivante :

- `age` : âge
- `class_of_worker` : type de l'emploi (gouvernement, auto-entrepreneur, privé)
- `detailed_industry_recode` : code de l'industrie où la personne travaille ([liste des codes](https://microdata.epi.org/variables/indocc/dind03/))
- `detailed_occupation_recode` : code du domaine de l'emploi de la personne ([liste des codes](https://www.icpsr.umich.edu/web/RCMD/studies/03303/datasets/0001/variables/PRDTOCC1?archive=RCMD))
- `education` : niveau d'éducation (lycée, université, ...)
- `wage_per_hour` : salaire horaire
- `enroll_in_edu_inst_last_wk` : inscription à une école la semaine dernière (lycée, université, ...)
- `marital_stat` : statut marital (marié, divorcé, veuf, ...)
- `major_industry_code` : nom de l'industrie principale où travaille la personne (agriculture, éducation, administration, ...)
- `major_occupation_code` : domaine de l'emploi principal de la personne (vente, pêche, forces armées, ...)
- `race` : ethnie (blanc, noir, asiatique, ...)
- `hispanic_origin` : pays d'origine de la personne (si elle est hispanique)
- `sex` : sexe (masculin, féminin)
- `member_of_a_labor_union` : appartenance à un syndicat (oui, non)
- `reason_for_unemployment` : raison du chômage (licenciement, départ, ...)
- `full_or_part_time_employment_stat` : statut d'emploi à temps plein ou partiel (temps plein, temps partiel (avec justification), ...)
- `capital_gains` : gains en capital
- `capital_losses` : pertes en capital
- `dividends_from_stocks` : dividendes des actions
- `tax_filer_stat` : statut de déclaration d'impôt (couple, célibataire, non déclarant, ...)
- `region_of_previous_residence` : région de la résidence précédente (nord, sud, est, ouest, à l'étranger)
- `state_of_previous_residence` : état de la résidence précédente (Floride, Californie, ...)
- `detailed_household_and_family_stat` : statut détaillé de la famille (exemple : enfant de + de 18 ans jamais marié)
- `detailed_household_summary_in_household` : statut détaillé de la famille dans le ménage (exemple : épouse du chef du ménage)
- `instance_weight` : poids de l'instance (pour la pondération, en fonction de la probabilité de l'observation)
- `migration_code-change_in_msa` : changement résidentiel, dans une zone métropolitaine différente
- `migration_code-change_in_reg` : changement résidentiel, dans une région différente mais dans le même pays
- `migration_code-move_within_reg` : changement résidentiel, dans la même région mais dans un autre état
- `live_in_this_house_1_year_ago` : habite dans la même maison depuis au moins un an
- `migration_prev_res_in_sunbelt` : changement résidentiel où la résidence précédente était dans le sud des États-Unis
- `num_persons_worked_for_employer` : nombre de personnes travaillant pour l'employeur de la personne
- `family_members_under_18` : Quand concerne des personnes ayant moins de 18ans, précise les membres de la famille présent (père, mère ou les deux)
- `country_of_birth_father` : pays de naissance du père de la personne
- `country_of_birth_mother` : pays de naissance de la mère de la personne
- `country_of_birth_self` : pays de naissance de la personne
- `citizenship` : citoyenneté (née aux États-Unis, née à l'étranger, ...)
- `own_business_or_self_employed` : propriétaire d'une entreprise ou auto-entrepreneur
- `fill_inc_questionnaire_for_veteran_admin` : a rempli un questionnaire de revenus pour l'administration des anciens combattants (oui, non)
- `veterans_benefits` : possède des avantages pour anciens combattants (oui, non)
- `weeks_worked_in_year` : nombre de semaines travaillées dans l'année
- `year` : année du recensement
- `income_level` : niveau de revenu (inférieur à 50k, supérieur à 50k)

Plus d'informations sur la signification des variables sont disponibles sur le site du [Census Bureau](https://www.census.gov/).



### Plan d'analyse

La présence de données ethniques est une des spécificités de ce jeu de données. Celles-ci ne sont en effet pas présentes dans les données issues des instituts français, empêchant de facto l'étude des inégalités liées à la race* sur une grande échelle.


-Nous avons donc décidé de profiter de la présence de l’attribut ethnique ("race") pour étudier l’impact de l’appartenance à un groupe racisé* sur la situation économique de la personne, et plus particulièrement sur son revenu.
Nous essaierons d’affiner notre analyse en croisant nos résultats avec d’autres données: 
-Le sexe ; Est-ce un facteur d’aggravation des inégalités raciales ?
-La situation géographique ; Le lieu de résidence (la Sunbelt par exemple) influe-t-il sur le niveau de vie et la qualité des emplois ?
- Le statut marital et la situation familiale ; Le mariage profite-t-il économiquement aux individus ? On pourra aussi pondérer les revenus en fonction du nombre de personnes composant les foyers.
-temporel (générations); Les enfants américains nés de parents étrangers sont-ils mieux intégrés au marché de l’emploi que leurs parents avant eux ?


Enfin, nous nous attacherons à essayer de comprendre les inégalités économiques. Pour cela nous nous pencherons sur les données structurelles : 
-Le niveau scolaire; La poursuite d’études permet-elle l’accès aux plus hauts revenus ? Élimine-t-elle le travail précaire ?
-La qualité de l’emploi (nombre de semaines travaillées, salaire horaire, cause du chômage, domaine d’activité, syndicat,); L’ethnie a-t-elle un impact sur les postes occupés et la rémunération des individus ? 
-Le capital



Il est tout de même important de noter que les données datent des années 90 et que les visualisations que nous allons réaliser ne seront pas forcément représentatives de la situation actuelle. Il sera donc nécessaire de replacer ces visualisations dans le contexte de l'époque afin de les interpréter correctement.


> *NB : “race” est un mot de vocabulaire employé dans le champ de la recherche en sociologie, en France comme aux Etats-Unis. 
