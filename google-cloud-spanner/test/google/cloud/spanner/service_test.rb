describe Google::Cloud::Spanner::Service do
    describe ".new" do
        it "sets quota_project with given value" do
            expected_quota_project = "test_quota_project"
            service = Google::Cloud::Spanner::Service.new(
                "test_project", nil, quota_project: expected_quota_project
              )
            assert_equal expected_quota_project, service.quota_project
        end

        it "sets quota_project from credentials if not given from config" do 
            expected_quota_project = "test_quota_project"
            service = Google::Cloud::Spanner::Service.new(
                "test_project", OpenStruct.new(quota_project_id: expected_quota_project)
              )
            assert_equal expected_quota_project, service.quota_project
        end
    end
end