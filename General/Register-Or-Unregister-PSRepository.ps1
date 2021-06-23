# Register the MyGet repository so it can be accessed/used
Register-PSRepository -Name MyGetCoditArcus -SourceLocation 'https://www.myget.org/F/arcus/api/v2/package'

# Verify if the requested module can be found in the new repository
Find-Module -Name Arcus.Scripting.Security -Repository MyGetCoditArcus

# Install the module that is located in the new repository
Install-Module Arcus.Scripting.DevOps -Repository MyGetCoditArcus

# Unregister/remove the repository to avoid overlap with the PSGallery
Unregister-PSRepository -Name MyGetCoditArcus