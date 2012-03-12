#
# Copyright (C) 2012 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe DiscussionTopic do
  it "should santize message" do
    course_model
    @course.discussion_topics.create!(:message => "<a href='#' onclick='alert(12);'>only this should stay</a>")
    @course.discussion_topics.first.message.should eql("<a href=\"#\">only this should stay</a>")
  end

  it "should update the assignment it is associated with" do
    course_model
    a = @course.assignments.create!(:title => "some assignment", :points_possible => 5)
    a.points_possible.should eql(5.0)
    a.submission_types.should_not eql("online_quiz")
    t = @course.discussion_topics.build(:assignment => a, :title => "some topic", :message => "a little bit of content")
    t.save
    t.assignment_id.should eql(a.id)
    t.assignment.should eql(a)
    a.reload
    a.discussion_topic.should eql(t)
    a.submission_types.should eql("discussion_topic")
  end

  it "should delete the assignment if the topic is no longer graded" do
    course_model
    a = @course.assignments.create!(:title => "some assignment", :points_possible => 5)
    a.points_possible.should eql(5.0)
    a.submission_types.should_not eql("online_quiz")
    t = @course.discussion_topics.build(:assignment => a, :title => "some topic", :message => "a little bit of content")
    t.save
    t.assignment_id.should eql(a.id)
    t.assignment.should eql(a)
    a.reload
    a.discussion_topic.should eql(t)
    t.assignment = nil
    t.save
    t.reload
    t.assignment_id.should eql(nil)
    t.assignment.should eql(nil)
    a.reload
    a.should be_deleted
  end

  it "should not grant permissions if it is locked" do
    course_with_teacher(:active_all => 1)
    student_in_course(:active_all => 1)
    @topic = @course.discussion_topics.create!(:user => @teacher)
    relevant_permissions = [:read, :reply, :update, :delete]
    (@topic.check_policy(@teacher) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply', 'update', 'delete'].sort
    (@topic.check_policy(@student) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply'].sort
    @topic.lock!
    (@topic.check_policy(@teacher) & relevant_permissions).map(&:to_s).sort.should == ['read', 'update', 'delete'].sort
    (@topic.check_policy(@student) & relevant_permissions).map(&:to_s).should == ['read']
    @topic.unlock!
    (@topic.check_policy(@teacher) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply', 'update', 'delete'].sort
    (@topic.check_policy(@student) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply'].sort

    @entry = @topic.discussion_entries.create!(:user => @teacher)
    @entry.discussion_topic = @topic
    (@entry.check_policy(@teacher) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply', 'update', 'delete'].sort
    (@entry.check_policy(@student) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply'].sort
    @topic.lock!
    (@topic.check_policy(@teacher) & relevant_permissions).map(&:to_s).sort.should == ['read', 'update', 'delete'].sort
    (@entry.check_policy(@student) & relevant_permissions).map(&:to_s).should == ['read']
    @topic.unlock!
    (@entry.check_policy(@teacher) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply', 'update', 'delete'].sort
    (@entry.check_policy(@student) & relevant_permissions).map(&:to_s).sort.should == ['read', 'reply'].sort
  end

  it "should grant observers read permission by default" do
    course_with_teacher(:active_all => true)
    course_with_observer(:course => @course, :active_all => true)
    relevant_permissions = [:read, :reply, :update, :delete]

    @topic = @course.discussion_topics.create!(:user => @teacher)
    (@topic.check_policy(@observer) & relevant_permissions).map(&:to_s).sort.should == ['read'].sort
    @entry = @topic.discussion_entries.create!(:user => @teacher)
    (@entry.check_policy(@observer) & relevant_permissions).map(&:to_s).sort.should == ['read'].sort
  end

  it "should not grant observers read permission when read_forum override is false" do
    course_with_teacher(:active_all => true)
    course_with_observer(:course => @course, :active_all => true)

    RoleOverride.create!(:context => @course.account, :permission => 'read_forum',
                         :enrollment_type => "ObserverEnrollment", :enabled => false)

    relevant_permissions = [:read, :reply, :update, :delete]
    @topic = @course.discussion_topics.create!(:user => @teacher)
    (@topic.check_policy(@observer) & relevant_permissions).map(&:to_s).should be_empty
    @entry = @topic.discussion_entries.create!(:user => @teacher)
    (@entry.check_policy(@observer) & relevant_permissions).map(&:to_s).should be_empty
  end

  context "delayed posting" do
    def delayed_discussion_topic(opts = {})
      @topic = @course.discussion_topics.build(opts)
      @topic.workflow_state = 'post_delayed'
      @topic.save!
      @topic
    end

    it "shouldn't send to streams on creation or update if it's delayed" do
      course_with_student(:active_all => true)
      @user.register
      topic = @course.discussion_topics.create!(:title => "this should not be delayed", :message => "content here")
      StreamItem.find_by_item_asset_string(topic.asset_string).should_not be_nil

      topic = delayed_discussion_topic(:title => "this should be delayed", :message => "content here", :delayed_post_at => Time.now + 1.day)
      StreamItem.find_by_item_asset_string(topic.asset_string).should be_nil

      topic.message = "content changed!"
      topic.save
      StreamItem.find_by_item_asset_string(topic.asset_string).should be_nil
    end

    it "should send to streams on update from delayed to active" do
      course_with_student(:active_all => true)
      @user.register
      topic = delayed_discussion_topic(:title => "this should be delayed", :message => "content here", :delayed_post_at => Time.now + 1.day)
      topic.workflow_state.should == 'post_delayed'
      StreamItem.find_by_item_asset_string(topic.asset_string).should be_nil

      topic.delayed_post_at = nil
      topic.title = "this isn't delayed any more"
      topic.workflow_state = 'active'
      topic.save!
      StreamItem.find_by_item_asset_string(topic.asset_string).should_not be_nil
    end
  end

  context "clone_for" do
    it "should clone to another context" do
      course_model
      topic = @course.discussion_topics.create!(:message => "<a href='#' onclick='alert(12);'>only this should stay</a>", :title => "some topic")
      course
      new_topic = topic.clone_for(@course)
      new_topic.context.should eql(@course)
      new_topic.context.should_not eql(topic.context)
      new_topic.message.should eql(topic.message)
      new_topic.title.should eql(topic.title)
    end
  end

  context "sub-topics" do
    it "should default subtopics_refreshed_at on save if a group assignment" do
      course_with_student(:active_all => true)
      group_category = @course.group_categories.create(:name => "category")
      @group = @course.groups.create(:name => "group", :group_category => group_category)
      @topic = @course.discussion_topics.create(:title => "topic")
      @topic.subtopics_refreshed_at.should be_nil

      @topic.assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title, :group_category => @group.group_category)
      @topic.assignment.infer_due_at
      @topic.assignment.saved_by = :discussion_topic
      @topic.save
      @topic.subtopics_refreshed_at.should_not be_nil
    end

    it "should not allow students to edit sub-topics" do
      course_with_student(:active_all => true)
      @first_user = @user
      @second_user = user_model
      @course.enroll_student(@second_user).accept
      @parent_topic = @course.discussion_topics.create!(:title => "parent topic", :message => "msg")
      @group = @course.groups.create!(:name => "course group")
      @group.add_user(@first_user)
      @group.add_user(@second_user)
      @group_topic = @group.discussion_topics.create!(:title => "group topic", :message => "ok to be edited", :user => @first_user)
      @sub_topic = @group.discussion_topics.build(:title => "sub topic", :message => "not ok to be edited", :user => @first_user)
      @sub_topic.root_topic_id = @parent_topic.id
      @sub_topic.save!
      @group_topic.grants_right?(@second_user, nil, :update).should eql(true)
      @sub_topic.grants_right?(@second_user, nil, :update).should eql(false)
    end
  end

  context "refresh_subtopics" do
    it "should be a no-op unless there's an assignment and it has a group_category" do
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.create(:title => "topic")
      @topic.refresh_subtopics.should be_nil
      @topic.reload.child_topics.should be_empty

      @topic.assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title)
      @topic.assignment.saved_by = :discussion_topic
      @topic.save
      @topic.refresh_subtopics.should be_nil
      @topic.reload.child_topics.should be_empty
    end

    it "should create a topic per active group in the category otherwise" do
      course_with_student(:active_all => true)
      group_category = @course.group_categories.create(:name => "category")
      @group1 = @course.groups.create(:name => "group 1", :group_category => group_category)
      @group2 = @course.groups.create(:name => "group 2", :group_category => group_category)

      @topic = @course.discussion_topics.build(:title => "topic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title, :group_category => @group1.group_category)
      @assignment.infer_due_at
      @assignment.saved_by = :discussion_topic
      @topic.assignment = @assignment
      @topic.save

      subtopics = @topic.refresh_subtopics
      subtopics.should_not be_nil
      subtopics.size.should == 2
      subtopics.each { |t| t.root_topic.should == @topic }
      @group1.reload.discussion_topics.should_not be_empty
      @group2.reload.discussion_topics.should_not be_empty
    end
  end

  context "root_topic?" do
    it "should be false if the topic has a root topic" do
      # subtopic has the assignment and group_category, but has a root topic
      course_with_student(:active_all => true)
      group_category = @course.group_categories.create(:name => "category")
      @parent_topic = @course.discussion_topics.create(:title => "parent topic")
      @subtopic = @parent_topic.child_topics.build(:title => "subtopic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @subtopic.title, :group_category => group_category)
      @assignment.infer_due_at
      @assignment.saved_by = :discussion_topic
      @subtopic.assignment = @assignment
      @subtopic.save

      @subtopic.should_not be_root_topic
    end

    it "should be false unless the topic has an assignment" do
      # topic has no root topic, but also has no assignment
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.create(:title => "subtopic")
      @topic.should_not be_root_topic
    end

    it "should be false unless the topic's assignment has a group_category" do
      # topic has no root topic and has an assignment, but the assignment has no group_category
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.create(:title => "topic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title)
      @assignment.infer_due_at
      @assignment.saved_by = :discussion_topic
      @topic.assignment = @assignment
      @topic.save

      @topic.should_not be_root_topic
    end

    it "should be true otherwise" do
      # topic meets all criteria
      course_with_student(:active_all => true)
      group_category = @course.group_categories.create(:name => "category")
      @topic = @course.discussion_topics.create(:title => "topic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title, :group_category => group_category)
      @assignment.infer_due_at
      @assignment.saved_by = :discussion_topic
      @topic.assignment = @assignment
      @topic.save

      @topic.should be_root_topic
    end
  end

  context "for_assignment?/for_group_assignment?" do
    it "should not be for_assignment?/for_group_assignment? unless it has an assignment" do
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.create(:title => "topic")
      @topic.should_not be_for_assignment
      @topic.should_not be_for_group_assignment

      group_category = @course.group_categories.build(:name => "category")
      @topic.assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title, :group_category => group_category)
      @topic.assignment.infer_due_at
      @topic.assignment.saved_by = :discussion_topic
      @topic.save
      @topic.should be_for_assignment
      @topic.should be_for_group_assignment
    end

    it "should not be for_group_assignment? unless the assignment has a group_category" do
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.build(:title => "topic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title)
      @assignment.infer_due_at
      @assignment.saved_by = :discussion_topic
      @topic.assignment = @assignment
      @topic.save
      @topic.should be_for_assignment
      @topic.should_not be_for_group_assignment

      @assignment.group_category = @course.group_categories.create(:name => "category")
      @assignment.save
      @topic.reload.should be_for_group_assignment
    end
  end

  context "should_send_to_stream" do
    it "should be true for non-assignment discussions" do
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.create(:title => "topic")
      @topic.should_send_to_stream.should be_true
    end

    it "should be true for non-group discussion assignments" do
      course_with_student(:active_all => true)
      @topic = @course.discussion_topics.build(:title => "topic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @topic.title, :due_at => 1.day.from_now)
      @assignment.saved_by = :discussion_topic
      @topic.assignment = @assignment
      @topic.save
      @topic.should_send_to_stream.should be_true
    end

    it "should be true for the parent topic only in group discussion assignments, not the subtopics" do
      course_with_student(:active_all => true)
      group_category = @course.group_categories.create(:name => "category")
      @parent_topic = @course.discussion_topics.create(:title => "parent topic")
      @subtopic = @parent_topic.child_topics.build(:title => "subtopic")
      @assignment = @course.assignments.build(:submission_types => 'discussion_topic', :title => @subtopic.title, :group_category => group_category, :due_at => 1.day.from_now)
      @assignment.saved_by = :discussion_topic
      @subtopic.assignment = @assignment
      @subtopic.save
      @parent_topic.should_send_to_stream.should be_true
      @subtopic.should_send_to_stream.should be_false
    end

    it "should not send stream items to students if course isn't published'" do
      course
      course_with_teacher(:course => @course, :active_all => true)
      student_in_course(:course => @course, :active_all => true)

      topic = @course.discussion_topics.create(:title => "secret topic", :user => @teacher)

      StreamItem.for_user(@student).count.should == 0
      StreamItem.for_user(@teacher).count.should == 1

      topic.discussion_entries.create!

      StreamItem.for_user(@student).count.should == 0
      StreamItem.for_user(@teacher).count.should == 1
    end

  end

  context "posting first to view" do
    before(:each) do
      course_with_student(:active_all => true)
      @observer = user(:active_all => true)
      course_with_teacher(:course => @course, :active_all => true)
      @context = @course
      discussion_topic_model
      @topic.require_initial_post = true
      @topic.save
    end

    it "should allow admins to see posts without posting" do
      @topic.user_can_see_posts?(@teacher).should == true
    end

    it "shouldn't allow student (and observer) who hasn't posted to see" do
      @topic.user_can_see_posts?(@student).should == false
    end

    it "should allow student (and observer) who has posted to see" do
      @topic.reply_from(:user => @student, :text => 'hai')
      @topic.user_can_see_posts?(@student).should == true
    end

  end

  context "posters" do
    before :each do
      @teacher = course_with_teacher(:active_all => true).user
      @context = @course
      discussion_topic_model(:user => @teacher)
    end

    it "should include the topic author" do
      @topic.posters.should include(@teacher)
    end

    it "should include users that have posted entries" do
      @student = student_in_course.user
      @topic.reply_from(:user => @student, :text => "entry")
      @topic.posters.should include(@student)
    end

    it "should include users that have replies to entries" do
      @entry = @topic.reply_from(:user => @teacher, :text => "entry")
      @student = student_in_course.user
      @entry.reply_from(:user => @student, :html => "reply")
      @topic.posters.should include(@student)
    end

    it "should dedupe users" do
      @entry = @topic.reply_from(:user => @teacher, :text => "entry")
      @student = student_in_course.user
      @entry.reply_from(:user => @student, :html => "reply 1")
      @entry.reply_from(:user => @student, :html => "reply 2")
      @topic.posters.should include(@teacher)
      @topic.posters.should include(@student)
      @topic.posters.size.should == 2
    end
  end

  context "submissions when graded" do
    before :each do
      @teacher = course_with_teacher(:active_all => true).user
      @context = @course
      discussion_topic_model(:user => @teacher)
    end

    def build_submitted_assignment
      student_in_course(:active_all => true)
      @assignment = @course.assignments.create!(:title => "some discussion assignment")
      @assignment.submission_types = 'discussion_topic'
      @assignment.save!
      @topic.assignment_id = @assignment.id
      @topic.save!
      @entry1 = @topic.discussion_entries.create!(:message => "second message", :user => @user)
      @entry1.created_at = 1.week.ago
      @entry1.save!
      @submission = @assignment.submissions.scoped(:conditions => {:user_id => @entry1.user_id}).first
    end

    it "should not re-flag graded discussion as needs grading if student make another comment" do
      pending('bug 6273 - do not re-flag graded discussion as needs grading if student make another comment') do
        student_enrollment = student_in_course(:name => 'student in course')
        student = student_enrollment.user
        assignment = @course.assignments.create(:title => "discussion assignment", :points_possible => 20)
        topic = @course.discussion_topics.create!(:title => 'discussion topic 1', :message => "this is a new discussion topic", :assignment => assignment)
        topic.discussion_entries.create!(:message => "student message for grading", :user => student)
        student_submission = Submission.last
        student_submission.assignment.grade_student(student, {:grade => 9})
        student_submission.reload
        student_submission.workflow_state.should == 'graded'
        topic.discussion_entries.create!(:message => "student message 2 for grading", :user => student)
        student_submission.reload
        student_submission.workflow_state.should == 'graded'
      end
    end

    it "should create submissions for existing entries when setting the assignment" do
      @student = student_in_course.user
      @topic.reply_from(:user => @student, :text => "entry")
      @student.reload
      @student.submissions.should be_empty

      @assignment = assignment_model(:course => @course)
      @topic.assignment = @assignment
      @topic.save
      @student.reload
      @student.submissions.size.should == 1
      @student.submissions.first.submission_type.should == 'discussion_topic'
    end

    it "should have the correct submission date if submission has comment" do
      student_in_course(:active_all => true)
      @assignment = @course.assignments.create!(:title => "some discussion assignment")
      @assignment.submission_types = 'discussion_topic'
      @assignment.save!
      @topic.assignment = @assignment
      @topic.save
      te = @course.enroll_teacher(user)
      @submission = @assignment.find_or_create_submission(@student.id)
      @submission_comment = @submission.add_comment(:author => te.user, :comment => "some comment")
      @submission.created_at = 1.week.ago
      @submission.save!
      @submission.workflow_state.should == 'unsubmitted'
      @submission.submitted_at.should be_nil
      @entry = @topic.discussion_entries.create!(:message => "somne discussion message", :user => @student)
      @submission.reload
      @submission.workflow_state.should == 'submitted'
      @submission.submitted_at.to_i.should >= @entry.created_at.to_i #this time may not be exact because it goes off of time.now in the submission
    end

    it "should fix submission date after deleting the oldest entry" do
      build_submitted_assignment()
      @entry2 = @topic.discussion_entries.create!(:message => "some message", :user => @user)
      @entry2.created_at = 1.day.ago
      @entry2.save!
      @entry1.destroy
      @topic.reload
      @topic.discussion_entries.should_not be_empty
      @topic.discussion_entries.active.should_not be_empty
      @submission.reload
      @submission.submitted_at.to_i.should == @entry2.created_at.to_i
      @submission.workflow_state.should == 'submitted'
    end

    it "should mark submission as unsubmitted after deletion" do
      build_submitted_assignment()
      @entry1.destroy
      @topic.reload
      @topic.discussion_entries.should_not be_empty
      @topic.discussion_entries.active.should be_empty
      @submission.reload
      @submission.workflow_state.should == 'unsubmitted'
      @submission.submission_type.should == nil
      @submission.submitted_at.should == nil
    end

    it "should have new submission date after deletion and re-submission" do
      build_submitted_assignment()
      @entry1.destroy
      @topic.reload
      @topic.discussion_entries.should_not be_empty
      @topic.discussion_entries.active.should be_empty
      @entry2 = @topic.discussion_entries.create!(:message => "some message", :user => @user)
      @submission.reload
      @submission.submitted_at.to_i.should >= @entry2.created_at.to_i #this time may not be exact because it goes off of time.now in the submission
      @submission.workflow_state.should == 'submitted'
    end

    it "should not duplicate submissions for existing entries that already have submissions" do
      @student = student_in_course.user
      @topic.reload # to get the student in topic.assignment.context.students

      @assignment = assignment_model(:course => @course)
      @topic.assignment = @assignment
      @topic.save

      @topic.reply_from(:user => @student, :text => "entry")
      @student.reload
      @student.submissions.size.should == 1
      @existing_submission_id = @student.submissions.first.id

      @topic.assignment = nil
      @topic.save
      @topic.reply_from(:user => @student, :text => "another entry")
      @student.reload
      @student.submissions.size.should == 1
      @student.submissions.first.id.should == @existing_submission_id

      @topic.assignment = @assignment
      @topic.save
      @student.reload
      @student.submissions.size.should == 1
      @student.submissions.first.id.should == @existing_submission_id
    end
  end

  context "read/unread state" do
    before(:each) do
      course_with_teacher(:active_all => true)
      student_in_course(:active_all => true)
      @topic = @course.discussion_topics.create!(:title => "title", :message => "message", :user => @teacher)
    end

    it "should mark a topic you created as read" do
      @topic.read?(@teacher).should be_true
      @topic.unread_count(@teacher).should == 0
    end

    it "should be unread by default" do
      @topic.read?(@student).should be_false
      @topic.unread_count(@student).should == 0
    end

    it "should allow being marked unread" do
      @topic.change_read_state("unread", @teacher)
      @topic.read?(@teacher).should be_false
      @topic.unread_count(@teacher).should == 0
    end

    it "should allow being marked read" do
      @topic.change_read_state("read", @student)
      @topic.read?(@student).should be_true
      @topic.unread_count(@student).should == 0
    end

    it "should allow mark all as unread" do
      @entry = @topic.discussion_entries.create!(:message => "Hello!", :user => @teacher)
      @topic.change_all_read_state("unread", @teacher)

      @topic.read?(@student).should be_false
      @entry.read?(@student).should be_false
      @topic.unread_count(@student).should == 1
    end

    it "should allow mark all as read" do
      @entry = @topic.discussion_entries.create!(:message => "Hello!", :user => @teacher)
      @topic.change_all_read_state("read", @student)

      @topic.read?(@student).should be_true
      @entry.read?(@student).should be_true
      @topic.unread_count(@student).should == 0
    end
  end

  context "materialized view" do
    def map_to_ids_and_replies(list)
      list.map { |l| l = l.slice('id', 'replies'); l['replies'] = map_to_ids_and_replies(l['replies'] || []); l }
    end

    it "should build a materialized view of the structure, participants and entry ids" do
      topic_with_nested_replies
      structure, participant_ids, entry_ids = @topic.materialized_view
      participant_ids.sort.should == [@student.id, @teacher.id].sort
      entry_ids.sort.should == @topic.discussion_entries.map(&:id).sort
      view = JSON.parse(structure)
      view.size.should == 2
      view.map { |e| e['id'] }.should == [@root1.id, @root2.id]
      view.map { |e| e['parent_id'] }.should == [nil, nil]
      view.map { |e| e['summary'] }.should == ['<p>root1</p>', '<p>root2</p>']
      deleted = view[0]['replies'][0]
      deleted['deleted'].should == true
      deleted['user_id'].should be_nil
      deleted['summary'].should be_nil
      # the deleted entry will be marked deleted and have no summary
      view = map_to_ids_and_replies(view)
      view.should == [
        {
          'id' => @root1.id,
          'replies' => [
            { 'id' => @reply1.id, 'replies' => [ { 'id' => @reply_reply2.id, 'replies' => [] } ], },
            { 'id' => @reply2.id, 'replies' => [ { 'id' => @reply_reply1.id, 'replies' => [] } ], },
          ],
        },
        {
          'id' => @root2.id,
          'replies' => [
            { 'id' => @reply3.id, 'replies' => [], },
          ],
        },
      ]
    end
  end
end
