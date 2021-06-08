Répertoire de dépôt d'autres exemples réalisés ou à venir

## Métadonnées définies dans un fichier Excel, pour une liste d'images drone et les produits dérivés

Excel_metadata_adapte_EVEX.r et metadata_ISO19115_EVEX_Partie1.xlsx, metadata_ISO19115_EVEX_Partie2.xlsx sont zippés dans un même dossier. 
Un exemple de fichier XML généré  est inclus, dans mdxml (180089013-FR-20190307-LIENSS_EVEX_Oleron07062016_0001)

Le fichier Excel contient plusieurs onglets, 
- **metadata** pour décrire les fichiers de données - des SHP ou des images, 1 jeu de données par ligne
- **contacts** pour décrire les contacts associés à ces jeux de données
- **boundingbox** correspond à l'emprise de chaque jeu de données - option à utiliser si vous ne faites pas calculer l'emprise automatiquement par le programme
- **listes** permet de définir les listes de valeurs à renseigner dans l'onglet *metadata*
- **codelist** donne des indications à l'utilisateur de thésaurus et de vocabulaires contrôlés pour l'aider à renseigner les mots clés et les thèmes.
- **guidelines** produit par Cécilia Pignon-Mussaud renseigne sur les valeurs attendues dans les colonnes de *metadata*

Il organise les données de façon hiérarchique, en rattachant certaines informations au jeu principal (identifié par parentIdentifier)
Par exemple, la ressource *180089013-FR-20190307-LIENSS_EVEX_Oleron07062016_0008* se rapporte au jeu de données	*180089013-FR-20190307-LIENSS_EVEX_Oleron07062016_0007*

Le code Excel_metadata_adapte_EVEX.r est très commenté. Il a été utilisé en Octobre 2020 avec R version 4.0.2. 








