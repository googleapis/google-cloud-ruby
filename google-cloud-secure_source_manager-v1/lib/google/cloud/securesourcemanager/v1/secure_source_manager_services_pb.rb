# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/securesourcemanager/v1/secure_source_manager.proto for package 'Google.Cloud.SecureSourceManager.V1'
# Original file comments:
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'grpc'
require 'google/cloud/securesourcemanager/v1/secure_source_manager_pb'

module Google
  module Cloud
    module SecureSourceManager
      module V1
        module SecureSourceManager
          # Secure Source Manager API
          #
          # Access Secure Source Manager instances, resources, and repositories.
          class Service

            include ::GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.securesourcemanager.v1.SecureSourceManager'

            # Lists Instances in a given project and location.
            rpc :ListInstances, ::Google::Cloud::SecureSourceManager::V1::ListInstancesRequest, ::Google::Cloud::SecureSourceManager::V1::ListInstancesResponse
            # Gets details of a single instance.
            rpc :GetInstance, ::Google::Cloud::SecureSourceManager::V1::GetInstanceRequest, ::Google::Cloud::SecureSourceManager::V1::Instance
            # Creates a new instance in a given project and location.
            rpc :CreateInstance, ::Google::Cloud::SecureSourceManager::V1::CreateInstanceRequest, ::Google::Longrunning::Operation
            # Deletes a single instance.
            rpc :DeleteInstance, ::Google::Cloud::SecureSourceManager::V1::DeleteInstanceRequest, ::Google::Longrunning::Operation
            # Lists Repositories in a given project and location.
            #
            # The instance field is required in the query parameter for requests using
            # the securesourcemanager.googleapis.com endpoint.
            rpc :ListRepositories, ::Google::Cloud::SecureSourceManager::V1::ListRepositoriesRequest, ::Google::Cloud::SecureSourceManager::V1::ListRepositoriesResponse
            # Gets metadata of a repository.
            rpc :GetRepository, ::Google::Cloud::SecureSourceManager::V1::GetRepositoryRequest, ::Google::Cloud::SecureSourceManager::V1::Repository
            # Creates a new repository in a given project and location.
            #
            # The Repository.Instance field is required in the request body for requests
            # using the securesourcemanager.googleapis.com endpoint.
            rpc :CreateRepository, ::Google::Cloud::SecureSourceManager::V1::CreateRepositoryRequest, ::Google::Longrunning::Operation
            # Updates the metadata of a repository.
            rpc :UpdateRepository, ::Google::Cloud::SecureSourceManager::V1::UpdateRepositoryRequest, ::Google::Longrunning::Operation
            # Deletes a Repository.
            rpc :DeleteRepository, ::Google::Cloud::SecureSourceManager::V1::DeleteRepositoryRequest, ::Google::Longrunning::Operation
            # Lists hooks in a given repository.
            rpc :ListHooks, ::Google::Cloud::SecureSourceManager::V1::ListHooksRequest, ::Google::Cloud::SecureSourceManager::V1::ListHooksResponse
            # Gets metadata of a hook.
            rpc :GetHook, ::Google::Cloud::SecureSourceManager::V1::GetHookRequest, ::Google::Cloud::SecureSourceManager::V1::Hook
            # Creates a new hook in a given repository.
            rpc :CreateHook, ::Google::Cloud::SecureSourceManager::V1::CreateHookRequest, ::Google::Longrunning::Operation
            # Updates the metadata of a hook.
            rpc :UpdateHook, ::Google::Cloud::SecureSourceManager::V1::UpdateHookRequest, ::Google::Longrunning::Operation
            # Deletes a Hook.
            rpc :DeleteHook, ::Google::Cloud::SecureSourceManager::V1::DeleteHookRequest, ::Google::Longrunning::Operation
            # Get IAM policy for a repository.
            rpc :GetIamPolicyRepo, ::Google::Iam::V1::GetIamPolicyRequest, ::Google::Iam::V1::Policy
            # Set IAM policy on a repository.
            rpc :SetIamPolicyRepo, ::Google::Iam::V1::SetIamPolicyRequest, ::Google::Iam::V1::Policy
            # Test IAM permissions on a repository.
            # IAM permission checks are not required on this method.
            rpc :TestIamPermissionsRepo, ::Google::Iam::V1::TestIamPermissionsRequest, ::Google::Iam::V1::TestIamPermissionsResponse
            # CreateBranchRule creates a branch rule in a given repository.
            rpc :CreateBranchRule, ::Google::Cloud::SecureSourceManager::V1::CreateBranchRuleRequest, ::Google::Longrunning::Operation
            # ListBranchRules lists branch rules in a given repository.
            rpc :ListBranchRules, ::Google::Cloud::SecureSourceManager::V1::ListBranchRulesRequest, ::Google::Cloud::SecureSourceManager::V1::ListBranchRulesResponse
            # GetBranchRule gets a branch rule.
            rpc :GetBranchRule, ::Google::Cloud::SecureSourceManager::V1::GetBranchRuleRequest, ::Google::Cloud::SecureSourceManager::V1::BranchRule
            # UpdateBranchRule updates a branch rule.
            rpc :UpdateBranchRule, ::Google::Cloud::SecureSourceManager::V1::UpdateBranchRuleRequest, ::Google::Longrunning::Operation
            # DeleteBranchRule deletes a branch rule.
            rpc :DeleteBranchRule, ::Google::Cloud::SecureSourceManager::V1::DeleteBranchRuleRequest, ::Google::Longrunning::Operation
            # Creates a pull request.
            rpc :CreatePullRequest, ::Google::Cloud::SecureSourceManager::V1::CreatePullRequestRequest, ::Google::Longrunning::Operation
            # Gets a pull request.
            rpc :GetPullRequest, ::Google::Cloud::SecureSourceManager::V1::GetPullRequestRequest, ::Google::Cloud::SecureSourceManager::V1::PullRequest
            # Lists pull requests in a repository.
            rpc :ListPullRequests, ::Google::Cloud::SecureSourceManager::V1::ListPullRequestsRequest, ::Google::Cloud::SecureSourceManager::V1::ListPullRequestsResponse
            # Updates a pull request.
            rpc :UpdatePullRequest, ::Google::Cloud::SecureSourceManager::V1::UpdatePullRequestRequest, ::Google::Longrunning::Operation
            # Merges a pull request.
            rpc :MergePullRequest, ::Google::Cloud::SecureSourceManager::V1::MergePullRequestRequest, ::Google::Longrunning::Operation
            # Opens a pull request.
            rpc :OpenPullRequest, ::Google::Cloud::SecureSourceManager::V1::OpenPullRequestRequest, ::Google::Longrunning::Operation
            # Closes a pull request without merging.
            rpc :ClosePullRequest, ::Google::Cloud::SecureSourceManager::V1::ClosePullRequestRequest, ::Google::Longrunning::Operation
            # Lists a pull request's file diffs.
            rpc :ListPullRequestFileDiffs, ::Google::Cloud::SecureSourceManager::V1::ListPullRequestFileDiffsRequest, ::Google::Cloud::SecureSourceManager::V1::ListPullRequestFileDiffsResponse
            # Fetches a tree from a repository.
            rpc :FetchTree, ::Google::Cloud::SecureSourceManager::V1::FetchTreeRequest, ::Google::Cloud::SecureSourceManager::V1::FetchTreeResponse
            # Fetches a blob from a repository.
            rpc :FetchBlob, ::Google::Cloud::SecureSourceManager::V1::FetchBlobRequest, ::Google::Cloud::SecureSourceManager::V1::FetchBlobResponse
            # Creates an issue.
            rpc :CreateIssue, ::Google::Cloud::SecureSourceManager::V1::CreateIssueRequest, ::Google::Longrunning::Operation
            # Gets an issue.
            rpc :GetIssue, ::Google::Cloud::SecureSourceManager::V1::GetIssueRequest, ::Google::Cloud::SecureSourceManager::V1::Issue
            # Lists issues in a repository.
            rpc :ListIssues, ::Google::Cloud::SecureSourceManager::V1::ListIssuesRequest, ::Google::Cloud::SecureSourceManager::V1::ListIssuesResponse
            # Updates a issue.
            rpc :UpdateIssue, ::Google::Cloud::SecureSourceManager::V1::UpdateIssueRequest, ::Google::Longrunning::Operation
            # Deletes an issue.
            rpc :DeleteIssue, ::Google::Cloud::SecureSourceManager::V1::DeleteIssueRequest, ::Google::Longrunning::Operation
            # Opens an issue.
            rpc :OpenIssue, ::Google::Cloud::SecureSourceManager::V1::OpenIssueRequest, ::Google::Longrunning::Operation
            # Closes an issue.
            rpc :CloseIssue, ::Google::Cloud::SecureSourceManager::V1::CloseIssueRequest, ::Google::Longrunning::Operation
            # Gets a pull request comment.
            rpc :GetPullRequestComment, ::Google::Cloud::SecureSourceManager::V1::GetPullRequestCommentRequest, ::Google::Cloud::SecureSourceManager::V1::PullRequestComment
            # Lists pull request comments.
            rpc :ListPullRequestComments, ::Google::Cloud::SecureSourceManager::V1::ListPullRequestCommentsRequest, ::Google::Cloud::SecureSourceManager::V1::ListPullRequestCommentsResponse
            # Creates a pull request comment.
            rpc :CreatePullRequestComment, ::Google::Cloud::SecureSourceManager::V1::CreatePullRequestCommentRequest, ::Google::Longrunning::Operation
            # Updates a pull request comment.
            rpc :UpdatePullRequestComment, ::Google::Cloud::SecureSourceManager::V1::UpdatePullRequestCommentRequest, ::Google::Longrunning::Operation
            # Deletes a pull request comment.
            rpc :DeletePullRequestComment, ::Google::Cloud::SecureSourceManager::V1::DeletePullRequestCommentRequest, ::Google::Longrunning::Operation
            # Batch creates pull request comments.
            rpc :BatchCreatePullRequestComments, ::Google::Cloud::SecureSourceManager::V1::BatchCreatePullRequestCommentsRequest, ::Google::Longrunning::Operation
            # Resolves pull request comments.
            rpc :ResolvePullRequestComments, ::Google::Cloud::SecureSourceManager::V1::ResolvePullRequestCommentsRequest, ::Google::Longrunning::Operation
            # Unresolves pull request comment.
            rpc :UnresolvePullRequestComments, ::Google::Cloud::SecureSourceManager::V1::UnresolvePullRequestCommentsRequest, ::Google::Longrunning::Operation
            # Creates an issue comment.
            rpc :CreateIssueComment, ::Google::Cloud::SecureSourceManager::V1::CreateIssueCommentRequest, ::Google::Longrunning::Operation
            # Gets an issue comment.
            rpc :GetIssueComment, ::Google::Cloud::SecureSourceManager::V1::GetIssueCommentRequest, ::Google::Cloud::SecureSourceManager::V1::IssueComment
            # Lists comments in an issue.
            rpc :ListIssueComments, ::Google::Cloud::SecureSourceManager::V1::ListIssueCommentsRequest, ::Google::Cloud::SecureSourceManager::V1::ListIssueCommentsResponse
            # Updates an issue comment.
            rpc :UpdateIssueComment, ::Google::Cloud::SecureSourceManager::V1::UpdateIssueCommentRequest, ::Google::Longrunning::Operation
            # Deletes an issue comment.
            rpc :DeleteIssueComment, ::Google::Cloud::SecureSourceManager::V1::DeleteIssueCommentRequest, ::Google::Longrunning::Operation
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
