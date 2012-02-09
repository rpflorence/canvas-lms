require File.expand_path(File.dirname(__FILE__) + '/common')

describe "discussion assignments" do
  it_should_behave_like "in-process server selenium tests"

  def build_assignment_with_type(text)
    get "/courses/#{@course.id}/assignments"

    driver.find_element(:css, ".header_content .add_assignment_link").click
    wait_for_animations

    click_option(".assignment_submission_types", text)
    driver.find_element(:css, "#add_assignment_form").submit
    wait_for_ajaximations
  end

  before (:each) do
    course_with_teacher_logged_in
  end

  it "should create a discussion topic when created" do
    build_assignment_with_type("Discussion")

    expect_new_page_load { driver.find_element(:css, "#left-side .discussions").click }
    driver.find_elements(:css, "#topic_list .discussion_topic").should_not be_empty
  end

  it "should redirect to the discussion topic" do
    build_assignment_with_type("Discussion")

    expect_new_page_load { driver.find_element(:css, ".assignment_list .group_assignment .assignment_title a").click }
    driver.current_url.should match %r{/courses/\d+/discussion_topics/\d+}
  end

  it "should create a discussion topic when edited from a regular assignment" do
    build_assignment_with_type("Assignment")

    expect_new_page_load { driver.find_element(:css, ".assignment_list .group_assignment .assignment_title a").click }
    driver.find_element(:css, ".edit_full_assignment_link").click
    wait_for_animations
    click_option(".assignment_type", "Discussion")
    driver.find_element(:css, "#edit_assignment_form").submit
    wait_for_ajaximations
    expect_new_page_load { driver.find_element(:css, ".assignment_topic_link").click }
    driver.current_url.should match %r{/courses/\d+/discussion_topics/\d+}
  end

  it "should create a discussion topic with requires peer reviews" do
    assignment_title = 'discussion assignment peer reviews'
    get "/courses/#{@course.id}/assignments"

    driver.find_element(:css, ".header_content .add_assignment_link").click
    wait_for_animations
    click_option(".assignment_submission_types", 'Discussion')
    expect_new_page_load { driver.find_element(:css, '.more_options_link').click }
    edit_form = driver.find_element(:id, 'edit_assignment_form')
    wait_for_tiny edit_form
    edit_form.should be_displayed
    replace_content(edit_form.find_element(:id, 'assignment_title'), assignment_title)
    edit_form.find_element(:id, 'assignment_peer_reviews').click
    edit_form.submit
    wait_for_ajaximations
    expect_new_page_load { driver.find_element(:link, assignment_title).click }
    driver.find_element(:css, '.for_assignment').should include_text('Grading will be based on posts submitted to this topic')
  end
end
