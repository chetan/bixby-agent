
COMMON_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../../../common/lib/common"))
if File.exists? COMMON_ROOT then
    # means we're runnin in a dev environment
    $:.unshift(COMMON_ROOT)
end
