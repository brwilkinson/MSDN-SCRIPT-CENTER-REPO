### URL for my Web Repo of Scripts: https://brwilkinson.github.io/msdn-scriptcenter-repo/
</br>

#### Instructions for hosting your own Script Center Scripts in your own repo

1) Go to your 'own' MSDN profile e.g. https://social.technet.microsoft.com/profile/ben%20wilkinson i.e. replace with your own link.
1) Log in
1) Click on the Privacy Tab
1) Click on the "CREATE" button next to "Collect your data from MSDN Code Gallery, TechNet Code Gallery all together"
1) Once it completes Download your ZIP of your scripts and extract it.
1) Fork this repo https://github.com/brwilkinson/msdn-scriptcenter-repo
1) Then Clone the fork "https://github.com/**yourusername**/msdn-scriptcenter-repo"
1) Place all of the Script Directories (from the script extract) into the project "artifacts" directory. E.g. each in it's own folder, a direct copy from what you downloaded.
1) Copy the metadata file E.g. gallery_{GUID}.json file from your download and copy it over the top of the _data\scripts.json file.
    1) For now we are only using the "userProject" array from the JSON object, you can choose to delete the other arraya/objects, if you like.
1) Execute the script in the scripts directory scripts\add-script-metadata.ps1
    1) This will recurse through all of the directories under artifacts and find only those with a nested ps1 file
        1) Adjust the filter if you have other types of scripts/files
        1) You will need to modify this if you have more than 1 Script
            - There is a link to the Directory anyway, so multiple scripts can be viewed there anyway
    1) The script will update the metadata in the data File to include the script path used to link to your scripts in github base repo directly
1) Update the _config.yml file with your GitHub Repo
    1) The "sourcebaseurl" that points to which ever branch you are using for your scripts
    1) The "url" which is the GitHubs Pages URL of your repo
    1) Other contact info on that page, for your GitHub pages website.
    1) I haven't tested other Themes, I tested only with: jekyll-theme-cayman
1) Enable "Pages" on the repo on GitHub settings: e.g. https://guides.github.com/features/pages/
1) Push your changes and test.
1) Feel free to reach out if you have any feedback, this was just a quick project to get access back to Search/Share my scripts Links.
    1) Viewing the Scripts on GitHub works really well, since that is what it was designed for  :)

### I am still wiring up the Tags, Categories, I will remove this comment once this is complete