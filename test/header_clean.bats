@test "Handle file renames" {
	output=$( load_fixture "file-rename" | $diff_so_fancy )
	run printf "%s" "$output"
	assert_line --index 1 --partial "renamed:"
	assert_line --index 1 --partial "Changes.new"
	assert_line --index 1 --partial "bin/"
}
