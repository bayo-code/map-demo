find . -name '*.java' -exec sed -i -e 's/app.organicmaps.R/com.mapmetrics.orgmaps.R/g' {} \;
find . -name '*.java' -exec sed -i -e 's/app.organicmaps.BuildConfig/com.mapmetrics.orgmaps.BuildConfig/g' {} \;
