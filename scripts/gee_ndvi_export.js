// Google Earth Engine Code Editor script
// Topic: district greenness and PM2.5 in Shenzhen, 2025

var DISTRICT_ASSET = 'projects/celtic-medium-511302-r5/assets/shenzhen_districts';
var districts = ee.FeatureCollection(DISTRICT_ASSET);

var start = '2025-01-01';
var end = '2026-01-01';
var ndviThreshold = 0.30;

function maskAndAddBands(image) {
  var scl = image.select('SCL');
  var landMask = scl.eq(4).or(scl.eq(5));
  var ndvi = image.normalizedDifference(['B8', 'B4']).rename('ndvi');
  var vegetated = ndvi.gte(ndviThreshold).multiply(100).rename('vegetated_pct');
  return image.addBands([ndvi, vegetated]).updateMask(landMask);
}

var s2 = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
  .filterBounds(districts.geometry())
  .filterDate(start, end)
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 80))
  .map(maskAndAddBands);

var annual = s2.select(['ndvi', 'vegetated_pct']).median();
var summary = annual.reduceRegions({
  collection: districts,
  reducer: ee.Reducer.mean().combine({
    reducer2: ee.Reducer.count(),
    sharedInputs: true
  }),
  scale: 10,
  tileScale: 4
}).map(function(feature) {
  return feature.set({
    year: 2025,
    ndvi_threshold: ndviThreshold,
    source: 'COPERNICUS/S2_SR_HARMONIZED',
    statistic: 'annual median image; district mean across valid land pixels'
  });
});

print('Sentinel-2 scenes used:', s2.size());
print('District greenness summary:', summary);
Map.centerObject(districts, 9);
Map.addLayer(annual.select('ndvi'), {
  min: 0,
  max: 0.8,
  palette: ['#f7fcf5', '#c7e9c0', '#74c476', '#238b45', '#00441b']
}, 'Annual median NDVI');
Map.addLayer(districts, {}, 'Shenzhen districts');

Export.table.toDrive({
  collection: summary,
  description: 'shenzhen_district_greenness_2025',
  fileNamePrefix: 'shenzhen_district_greenness_2025',
  fileFormat: 'CSV',
  selectors: [
    'dist_id', 'district', 'dist_zh', 'ndvi_mean', 'vegetated_pct_mean',
    'ndvi_count', 'vegetated_pct_count', 'year', 'ndvi_threshold', 'source'
  ]
});
