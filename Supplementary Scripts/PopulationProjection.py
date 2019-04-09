# -*- coding: utf-8 -*-
"""
Created on Tue Jan 15 09:41:21 2019

@author: medsthe
"""
import pandas as pd
import ukpopulation.snppdata as SNPPData
snpp = SNPPData.SNPPData()
leeds=snpp.aggregate(["GENDER"], "E08000035", range(2018,2050), ages=range(16,91))
leeds.head()
leeds.to_csv("PopulationProjection.csv")


import ukcensusapi.Nomisweb as CensusApi
import ukpopulation.snppdata as SNPPData

otley = ["E02002185", "E02002187", "E02002332", "E02002333", "E02002336", "E02002337",  "E02002338",  "E02002339", "E02002340", "E02002342", "E02002343", "E02002345", "E02002346","E02002348", "E02002350", "E02002356", "E02002357"]
leeds = "E08000035"
year = 2018
census_api = CensusApi.Nomisweb("./cache")
table = "KS102EW"
query_params = {
  "date": "latest",
  "select": "GEOGRAPHY_CODE,CELL,OBS_VALUE",
  "RURAL_URBAN": "0",
  "CELL": "6...16", # age groups from 16 tp 90+
  "MEASURES": "20100",
  "geography": "1245710558...1245710660,1245714998...1245714998,1245715007...1245715007,1245715021...1245715022"
}

# aggregate age groups and sum
leedspop = census_api.get_data(table, query_params).groupby(["GEOGRAPHY_CODE"]).sum().drop("CELL", axis=1)

# work out proportion of Leeds population for the 2 MSOAs
leedspop["PROP"] = leedspop.OBS_VALUE / sum(leedspop.OBS_VALUE)
leedspop.rename({"OBS_VALUE": "POP_2011"}, axis=1, inplace=True)

# get Leeds population for e.g. 2018
leedsproj = snpp.aggregate(["C_AGE", "GENDER"], leeds, year, ages=range(16,91)).set_index("GEOGRAPHY_CODE")

# scale leeds 2018 population by the MSOA proportions
leedspop["POP_"+str(year)] = leedspop["PROP"] * leedsproj.loc["E08000035", "OBS_VALUE"]

leedsproj.head()
print(leedspop.loc[otley])
print(leedsproj)
leedspop.loc[otley].to_csv("LADtoMSOA.csv")



#Same procedure for Bradford -------------------------------------------------------------------------------------------------------------
import pandas as pd
import ukpopulation.snppdata as SNPPData
snpp = SNPPData.SNPPData()
bradford=snpp.aggregate(["GENDER"], "E08000032", range(2018,2050), ages=range(18,89))
bradford.head()
#bradford.to_csv("PopulationProjectionBradford.csv")

import ukcensusapi.Nomisweb as CensusApi
import ukpopulation.snppdata as SNPPData

otley = ["E02002185", "E02002187"]
leeds = "E08000032"
year = 2018
census_api = CensusApi.Nomisweb("./cache")
table = "KS102EW"

coverage = ["Bradford"]
resolution = CensusApi.Nomisweb.GeoCodeLookup["MSOA11"]
coverage_codes = census_api.get_lad_codes(coverage)

query_params = {
  "date": "latest",
  "select": "GEOGRAPHY_CODE,CELL,OBS_VALUE",
  "RURAL_URBAN": "0",
  "CELL": "6...16", # age groups from 16 tp 90+
  "MEASURES": "20100",
  "geography": census_api.get_geo_codes(coverage_codes, resolution)
}

# aggregate age groups and sum
leedspop = census_api.get_data(table, query_params).groupby(["GEOGRAPHY_CODE"]).sum().drop("CELL", axis=1)

# work out proportion of Leeds population for the 2 MSOAs
leedspop["PROP"] = leedspop.OBS_VALUE / sum(leedspop.OBS_VALUE)
leedspop.rename({"OBS_VALUE": "POP_2011"}, axis=1, inplace=True)

# get Leeds population for e.g. 2018
leedsproj = snpp.aggregate(["C_AGE", "GENDER"], leeds, year, ages=range(16,91)).set_index("GEOGRAPHY_CODE")

# scale leeds 2018 population by the MSOA proportions
leedspop["POP_"+str(year)] = leedspop["PROP"] * leedsproj.loc["E08000032", "OBS_VALUE"]

leedsproj.head()
print(leedspop.loc[otley])
leedspop.loc[otley].to_csv("LADtoMSOABradford.csv")

#Same procedure for Adel and Wharfdale -------------------------------------------------------------------------------------------------------------


