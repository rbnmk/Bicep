param location string = 'westeurope'
param galleryName string
param tags object = {}

//Create Gallery
resource aibgallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: galleryName
  location: location
  tags: tags
}

output galleryName string = aibgallery.name
