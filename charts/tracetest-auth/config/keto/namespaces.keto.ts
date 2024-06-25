import { Namespace, SubjectSet } from "@ory/keto-namespace-types";

export class User implements Namespace {}
export class Token implements Namespace {}
export class Group implements Namespace {
  related: {
    member: (User | Group)[];
  };
}

export class EnvGroup implements Namespace {
  related: {
    member: (User | Token | Group)[];
  };
}

export class Organization implements Namespace {
  related: {
    view: Group[];
    edit: SubjectSet<Group, "member">[];
    bill: SubjectSet<Group, "member">[];
    agent: SubjectSet<Group, "member">[];

    invite: OrganizationInvite[];
    environments: Environment[];
  };
}

export class OrganizationInvite implements Namespace {
  related: {
    accept: User[];
  };
}

export class EnvironmentInvite implements Namespace {
  related: {
    accept: User[];
  };
}

// Environments
export class Environment implements Namespace {
  related: {
    view: SubjectSet<EnvGroup, "member">[];
    // settings
    edit: SubjectSet<EnvGroup, "member">[];

    // tests, test suites, test runs, test suites, variable sets etc.
    configure: SubjectSet<EnvGroup, "member">[];

    agent: SubjectSet<EnvGroup, "member">[];
  };
}

export class LocalEnvironment implements Namespace {
  related: {
    own: User[];
  };
}
