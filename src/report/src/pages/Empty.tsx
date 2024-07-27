import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function Empty() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Empty Page</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle>Card Title</CardTitle>
                    <CardDescription>Card description.</CardDescription>
                </CardHeader>
            </Card>
        </>
    )
}
