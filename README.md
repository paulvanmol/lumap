# Luxembourg Maps for SAS

Custom geographic maps of Luxembourg for use with SAS Visual Analytics 7.x and SAS 9.4M6+. This repository provides ready-to-use map boundaries for Luxembourg at three administrative levels: Districts, Cantons, and Municipalities (Communes).

## Overview

This project enables visualization of Luxembourg geographic data in SAS Visual Analytics and other SAS tools using official administrative boundaries from the Luxembourg Public Data Portal. The maps support both WGS84 (EPSG:4326) and LUREF (EPSG:2169) coordinate systems.

### Features

- **Three Administrative Levels**: Districts, Cantons, and Municipalities
- **Multiple Coordinate Systems**: WGS84 for Visual Analytics 7.x, LUREF for other SAS tools
- **Encoding Support**: Both UTF-8 and Latin1 versions available
- **Standard Identifiers**: Uses LAU codes (Eurostat) and ISO 3166-2 codes
- **Ready-to-Use**: Includes master import script and sample datasets
- **PROC SGMAP Examples**: Code examples for geocoding and mapping

## Data Source

Map polygons are sourced from the **Luxembourg Public Data Portal**:

- **Dataset**: [Administrative Boundaries of Luxembourg](https://data.public.lu/en/datasets/limites-administratives-du-grand-duche-de-luxembourg/)
- **Original Projection**: LUREF (EPSG:2169)
- **Converted Projection**: WGS84 (EPSG:4326) for Visual Analytics 7.x compatibility

Address geocoding data is also available from:
- [Georeferenced Addresses (BD Adresses)](https://data.public.lu/en/datasets/adresses-georeferencees-bd-adresses/)

## Repository Structure

```
lumap/
├── limadmin/              # Shape files for Luxembourg administrative boundaries
│   ├── *_WGS84_UTF8.shp  # WGS84 projection, UTF-8 encoding
│   ├── *_WGS84_Latin1.shp # WGS84 projection, Latin1 encoding
│   ├── *_LUREF_UTF8.shp  # LUREF projection, UTF-8 encoding (for non-VA usage)
│   └── ...               # Associated .shx, .dbf, .prj files
├── sasdata/              # SAS datasets for maps
│   ├── ATTRLOOKUP.sas7bdat    # Attribute lookup table (backup and update)
│   ├── CENTLOOKUP.sas7bdat    # Centroid lookup table (backup and update)
│   ├── MAPCSTM_*.sas7bdat     # Custom map datasets
│   └── CUSTOMLU1_POPAREA.sas7bdat  # Sample data: population & area by municipality
├── sascode/              # SAS programs and examples
│   ├── MasterScriptLU.sas           # Main import script
│   └── Example_GeocodingLUAddresses.sas  # PROC SGMAP example
└── README.md
```

## Geographic Identifiers

### Municipalities (Communes)
Uses **LAU codes** (Local Administrative Unit Level 2) from Eurostat with prefix `ZL-`:
- Example: `ZL-0101` for Luxembourg City
- All codes start with the non-standard prefix `ZL-` to distinguish Luxembourg municipalities
- Join your data to `MAPCSTM_MUNLU1_TEST` to lookup correct codes

### Cantons
Uses **ISO 3166-2:LU** codes:

| Code   | Canton              |
|--------|---------------------|
| LU-CA  | Capellen            |
| LU-CL  | Clervaux            |
| LU-DI  | Diekirch            |
| LU-EC  | Echternach          |
| LU-ES  | Esch-sur-Alzette    |
| LU-GR  | Grevenmacher        |
| LU-LU  | Luxembourg          |
| LU-ME  | Mersch              |
| LU-RE  | Redange             |
| LU-RM  | Remich              |
| LU-VD  | Vianden             |
| LU-WI  | Wiltz               |

### Districts
Uses custom identifiers (fictive codes):
- `ZD-1`: District Diekirch
- `ZD-2`: District Grevenmacher
- `ZD-3`: District Luxembourg

## Installation

### Prerequisites

- SAS 9.4M6 or higher
- SAS Visual Analytics 7.x (for VA usage)
- Access to SAS configuration directory
- Appropriate permissions to modify server configuration

### Setup Instructions

1. **Download and Extract**
   ```
   Unzip lumapsv2_20200618.zip to your desired location
   Example: D:/workshop/lumap
   ```

2. **Configure Master Script**
   
   Open `MasterScriptLU.sas` in SAS Enterprise Guide or SAS Studio and update:
   
   ```sas
   /* Set the path to your lumap folder */
   %let path = D:/workshop/lumap;
   
   /* Choose encoding: utf8 or latin1 */
   %let encoding = utf8;
   ```

3. **Create MAPSCSTM Library**
   
   **Important**: This library must be available at SASApp server startup.
   
   a. Backup your configuration file:
   ```
   /SAS/Config/Lev1/SASApp/appserver_autoexec_usermods.sas
   ```
   
   b. Add the following code to assign the library:
   ```sas
   /* Custom MAPS library for SAS Visual Analytics */
   libname mapscstm "<yourpath>/lumap/sasdata";
   ```
   
   c. Restart the SASApp server

4. **Backup Existing Lookup Tables**
   
   Before running the master script, backup the existing tables in the `valib` library:
   - `ATTRLOOKUP`
   - `CENTLOOKUP`
   
   Backup copies are included in the MAPSCSTM library.

5. **Run the Master Script**
   
   Execute `MasterScriptLU.sas` on your SASApp server. This will:
   - Import shape files
   - Create custom map datasets
   - Update ATTRLOOKUP and CENTLOOKUP tables

## Usage

### SAS Visual Analytics 7.x

#### Municipalities Map

1. In your VA report, add a geo map visualization
2. Join your data to the `MAPCSTM_MUNLU1_TEST` dataset using LAU codes
3. Use the sample dataset `CUSTOMLU1_POPAREA` as a reference (contains population and area by municipality)
4. The map will display municipalities with your measures

**Example**: Visualizing population density:
- Geographic item: Municipality (LAU code with `ZL-` prefix)
- Measure: Population or Area
- Color: Based on your measure values

#### Cantons Map

1. Use ISO 3166-2 canton codes in your data (e.g., `LU-LU`, `LU-ES`)
2. The canton boundaries will automatically render in Visual Analytics
3. Apply measures and colors as needed

#### Districts Map

1. Use the custom district codes: `ZD-1`, `ZD-2`, `ZD-3`
2. Map to the three Luxembourg districts
3. Ideal for high-level regional analysis

### SAS Studio / Enterprise Guide (Non-VA Usage)

For use with PROC SGMAP or other SAS procedures, consider using the **LUREF projection** instead of WGS84 for better accuracy with Luxembourg-specific data.

#### Example: Geocoding Luxembourg Addresses

See `Example_GeocodingLUAddresses.sas` for a complete example.

**Requirements**:
- SAS session with UTF-8 encoding support
- LUREF projection shape files
- Address data from Luxembourg Public Data Portal

**Sample Code Pattern**:
```sas
proc sgmap mapdata=mapscstm.municip_luref;
  /* Display choropleth map of municipalities */
  choromap id / mapid=lau_code;
  
  /* Overlay geocoded addresses */
  scatter x=longitude y=latitude / 
    markerattrs=(symbol=circlefilled size=5px);
run;
```

**PROC SGMAP Features**:
- Combine choromap (municipality boundaries) with scatter plots (addresses)
- Geocode addresses using numero, rue, localite, and postal code
- Available since SAS 9.4M5 (use PROC GMAP for earlier versions)

## Coordinate Systems

### WGS84 (EPSG:4326)
- **Use for**: SAS Visual Analytics 7.x
- **Shape files**: `*_WGS84_*.shp`
- **Standard**: Global coordinate system

### LUREF (EPSG:2169)
- **Use for**: PROC SGMAP, PROC GMAP, other SAS tools
- **Shape files**: `*_LUREF_*.shp`
- **Standard**: Luxembourg-specific coordinate system
- **Advantage**: Higher accuracy for Luxembourg-specific applications

## Encoding

Two encoding versions are provided:

- **UTF-8**: Recommended for most modern environments, properly handles accented characters in commune names
- **Latin1**: For legacy SAS 9.4 environments that use Latin1 encoding

Choose the version matching your SAS session encoding to ensure proper display of special characters (é, è, à, etc.) in Luxembourg place names.

## Sample Data

### CUSTOMLU1_POPAREA
Included sample dataset with:
- Municipality LAU codes
- Population figures
- Area measurements
- Example for joining your own data

Use this as a template for preparing your data for visualization.

## Troubleshooting

### Maps not appearing in Visual Analytics
- Verify MAPSCSTM library is assigned at server startup
- Check that ATTRLOOKUP and CENTLOOKUP were updated correctly
- Restart SASApp server after configuration changes

### Encoding issues (accented characters display incorrectly)
- Ensure you're using the correct encoding version (UTF-8 vs Latin1)
- Match the shape file encoding to your SAS session encoding
- Verify the `%let encoding` macro variable in MasterScriptLU.sas

### Geographic identifiers not matching
- For municipalities: Ensure you're using LAU codes with `ZL-` prefix
- For cantons: Use ISO 3166-2 codes (e.g., `LU-LU`, not just `LU`)
- For districts: Use custom codes `ZD-1`, `ZD-2`, `ZD-3`

### PROC SGMAP not available
- PROC SGMAP requires SAS 9.4M5 or higher
- For earlier versions, use PROC GMAP instead
- Ensure SAS/GRAPH is licensed and installed

## Technical Notes

### Shape File Conversion
Original shape files from Luxembourg Public Data Portal are in LUREF projection. Conversion to WGS84 was performed using QGIS:

1. Verified layer properties (Encoding: UTF-8, Projection: EPSG:2169)
2. Exported to WGS84 projection (EPSG:4326)
3. Created separate versions for UTF-8 and Latin1 encoding
4. Preserved all attribute data during conversion

### Visual Analytics Compatibility
- **VA 7.x**: Requires WGS84 projection (EPSG:4326)
- **VA 8.x**: Supports both WGS84 and LUREF projections

### Lookup Table Updates
The master script updates two critical Visual Analytics tables:
- **ATTRLOOKUP**: Maps geographic identifiers to custom map datasets
- **CENTLOOKUP**: Stores centroid coordinates for each geographic area

Always backup these tables before running the import script.

## Use Cases

- **Demographic Analysis**: Visualize population distribution across municipalities
- **Sales Territory Mapping**: Display sales performance by canton or municipality
- **Public Health Dashboards**: Map health metrics across Luxembourg regions
- **Real Estate Analysis**: Show property data by geographic area
- **Retail Location Planning**: Analyze customer distribution and store coverage
- **Government Reporting**: Create official reports with accurate administrative boundaries

## Contributing

Contributions are welcome! Potential improvements:
- Updated shape files as boundaries change
- Additional sample datasets
- More PROC SGMAP examples
- Integration examples with other SAS tools

## References

- [Luxembourg Public Data Portal](https://data.public.lu/)
- [Administrative Boundaries Dataset](https://data.public.lu/en/datasets/limites-administratives-du-grand-duche-de-luxembourg/)
- [Georeferenced Addresses](https://data.public.lu/en/datasets/adresses-georeferencees-bd-adresses/)
- [Eurostat LAU Codes](https://ec.europa.eu/eurostat/web/nuts/local-administrative-units)
- [ISO 3166-2:LU](https://en.wikipedia.org/wiki/ISO_3166-2:LU)

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0) - see the [LICENSE](LICENSE) file for details.

Map data is sourced from Luxembourg's Public Data Portal under their terms of use.

## Contact

Paul Van Mol - [https://github.com/paulvanmol](https://github.com/paulvanmol)

---

**Note**: This project provides custom geographic maps for demonstration and analysis purposes. For production use, verify that boundary data is current and meets your accuracy requirements.
