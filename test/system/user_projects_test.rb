require "application_system_test_case"

class UserProjectsTest < ApplicationSystemTestCase
  setup do
    @user_project = user_projects(:one)
  end

  test "visiting the index" do
    visit user_projects_url
    assert_selector "h1", text: "User projects"
  end

  test "should create user project" do
    visit user_projects_url
    click_on "New user project"

    fill_in "Project", with: @user_project.project_id
    fill_in "User", with: @user_project.user_id
    click_on "Create User project"

    assert_text "User project was successfully created"
    click_on "Back"
  end

  test "should update User project" do
    visit user_project_url(@user_project)
    click_on "Edit this user project", match: :first

    fill_in "Project", with: @user_project.project_id
    fill_in "User", with: @user_project.user_id
    click_on "Update User project"

    assert_text "User project was successfully updated"
    click_on "Back"
  end

  test "should destroy User project" do
    visit user_project_url(@user_project)
    click_on "Destroy this user project", match: :first

    assert_text "User project was successfully destroyed"
  end
end