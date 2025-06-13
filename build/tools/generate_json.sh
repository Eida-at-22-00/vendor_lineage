#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <TARGET_DEVICE> <PRODUCT_OUT> <FILENAME>"
    exit 1
fi

TARGET_DEVICE=$1
PRODUCT_OUT=$2
LINEAGE_ZIP=$3
FILENAME="axion-$LINEAGE_ZIP"

if [[ "$FILENAME" =~ axion-.*-(COMMUNITY|OFFICIAL|UNOFFICIAL)-.*\.zip ]]; then
    ROMTYPE="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract ROM type from filename: $FILENAME"
    exit 1
fi

if [[ "$FILENAME" =~ axion-([0-9\.]+)(-[A-Za-z]+)?-[0-9]+-$ROMTYPE-.*\.zip ]]; then
    VERSION="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract version from filename: $FILENAME"
    exit 1
fi

if [[ "$FILENAME" =~ axion-.*-$ROMTYPE-(GMS|VANILLA)-.*\.zip ]]; then
    FLAVOR="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract build flavor from filename: $FILENAME"
    exit 1
fi

FILE_PATH="$PRODUCT_OUT/$FILENAME"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

SIZE=$(stat -c%s "$FILE_PATH")
ID=$(md5sum "$FILE_PATH" | awk '{print $1}')
DATETIME=$(date +%s)

JSON_DIR="$PRODUCT_OUT/$FLAVOR"
if [ ! -d "$JSON_DIR" ]; then
    mkdir -p "$JSON_DIR"
fi
JSON_FILE="$JSON_DIR/${TARGET_DEVICE}.json"

cat > "$JSON_FILE" <<EOF
{
    "response": [
        {
            "datetime": $DATETIME,
            "filename": "$FILENAME",
            "id": "$ID",
            "romtype": "$ROMTYPE",
            "size": $SIZE,
            "url": "https://github.com/AxionAOSP/AxionOS_Pixels/releases/download/$VERSION/$FILENAME",
            "version": "$VERSION"
        }
    ]
}
EOF

echo "JSON saved to: $JSON_FILE"
cat "$JSON_FILE"

echo "=========================================="
echo -e "         ${RED}Welcome to the Axion${NC}             "
echo "=========================================="
echo -e "        ${GREEN}BUILD COMPLETED SUCCESSFULLY${NC}      "
echo "------------------------------------------"
echo "Datetime : $DATETIME"
echo "Size     : $(numfmt --to=iec $SIZE) ($SIZE bytes)"
echo -e "Output   : ${BLUE}$FILE_PATH${NC}"
echo "=========================================="

exit 0
