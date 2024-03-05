terraform output key_data > key
sed -i '' -e '$ d' key
sed -i '' -e '1 d' key
chmod 600 key